local fastRetryDelay = 0.03
local slowRetryDelay = 0.12
local chromeCycleTraceEnabled = true
local activeChromeCycleTrace = nil
local chromeCycleOrder = {}
local activeChromeHighlight = nil

local function nowMs()
  return hs.timer.absoluteTime() / 1000000
end

local function startChromeCycleTrace()
  if not chromeCycleTraceEnabled then
    activeChromeCycleTrace = nil
    return
  end

  local now = nowMs()
  activeChromeCycleTrace = {
    start = now,
    last = now,
  }
  print("[chrome-cycle] start")
end

local function traceChromeCycle(label)
  local trace = activeChromeCycleTrace
  if not trace then
    return
  end

  local now = nowMs()
  print(string.format(
    "[chrome-cycle] +%.1fms total=%.1fms %s",
    now - trace.last,
    now - trace.start,
    label
  ))
  trace.last = now
end

local function finishChromeCycleTrace(label)
  traceChromeCycle(label or "finish")
  activeChromeCycleTrace = nil
end

local function splitLines(text)
  local lines = {}
  for line in tostring(text or ""):gmatch("[^\r\n]+") do
    lines[#lines + 1] = line
  end
  return lines
end

local function splitFirst(text, delimiter)
  local pos = tostring(text):find(delimiter, 1, true)
  if not pos then
    return text, ""
  end
  return text:sub(1, pos - 1), text:sub(pos + #delimiter)
end

local function chromeWindowSnapshot()
  local start = nowMs()
  local ok, result = hs.osascript.applescript([[
set AppleScript's text item delimiters to linefeed
tell application "Google Chrome"
  set fieldSeparator to ASCII character 9
  set windowCount to count of windows
  if windowCount is 0 then
    return "0" & fieldSeparator & "" & fieldSeparator & ""
  end if

  set frontId to (id of front window) as text
  set rows to {}
  repeat with w in every window
    set b to bounds of w
    set end of rows to ((id of w) as text) & fieldSeparator & (title of w) & fieldSeparator & ((item 1 of b) as text) & fieldSeparator & ((item 2 of b) as text) & fieldSeparator & ((item 3 of b) as text) & fieldSeparator & ((item 4 of b) as text)
  end repeat
  return (windowCount as text) & fieldSeparator & frontId & fieldSeparator & (rows as text)
end tell
]])
  if not ok then
    traceChromeCycle(string.format("AppleScript chromeWindowSnapshot failed %.1fms", nowMs() - start))
    return nil, result
  end

  local countText, rest = splitFirst(result, "\t")
  local frontId, rowsText = splitFirst(rest, "\t")
  local snapshot = {
    count = tonumber(countText) or 0,
    frontId = frontId,
    windows = {},
  }

  for _, row in ipairs(splitLines(rowsText)) do
    local id, rest = splitFirst(row, "\t")
    local title, rest2 = splitFirst(rest, "\t")
    local left, rest3 = splitFirst(rest2, "\t")
    local top, rest4 = splitFirst(rest3, "\t")
    local right, bottom = splitFirst(rest4, "\t")
    if id ~= "" then
      local x = tonumber(left)
      local y = tonumber(top)
      local r = tonumber(right)
      local b = tonumber(bottom)
      snapshot.windows[#snapshot.windows + 1] = {
        id = id,
        title = title,
        bounds = x and y and r and b and {
          x = x,
          y = y,
          w = r - x,
          h = b - y,
        } or nil,
      }
    end
  end

  traceChromeCycle(string.format(
    "AppleScript chromeWindowSnapshot count=%d %.1fms",
    snapshot.count,
    nowMs() - start
  ))
  return snapshot, nil
end

local function chromeFrontWindowId()
  local start = nowMs()
  local ok, result = hs.osascript.applescript([[
tell application "Google Chrome"
  if (count of windows) is 0 then
    return ""
  end if
  return (id of front window) as text
end tell
]])
  if not ok then
    traceChromeCycle(string.format("AppleScript chromeFrontWindowId failed %.1fms", nowMs() - start))
    return nil
  end

  traceChromeCycle(string.format("AppleScript chromeFrontWindowId %.1fms id=%s", nowMs() - start, result))
  return result
end

local function selectChromeWindow(title)
  local start = nowMs()
  local app = hs.application.get("com.google.Chrome") or hs.application.find("Google Chrome")
  if not app then
    traceChromeCycle(string.format("selectChromeWindow app missing %.1fms", nowMs() - start))
    return false, "Google Chrome is not running"
  end

  if app:selectMenuItem({"Window", title}) then
    traceChromeCycle(string.format("selectChromeWindow success %.1fms", nowMs() - start))
    return true, nil
  end

  traceChromeCycle(string.format("selectChromeWindow menu missing %.1fms", nowMs() - start))
  return false, "Chrome Window menu item not found"
end

local function titleMatchesWindow(menuTitle, windowTitle)
  if tostring(windowTitle):find(menuTitle, 1, true) then
    return true
  end

  local prefix, suffix = tostring(menuTitle):match("^(.-)…(.*)$")
  if prefix and suffix then
    return windowTitle:find(prefix, 1, true) and windowTitle:find(suffix, 1, true)
  end

  return false
end

local function activateChrome()
  local start = nowMs()
  local app = hs.application.get("com.google.Chrome") or hs.application.find("Google Chrome")
  if not app then
    traceChromeCycle(string.format("activateChrome app missing %.1fms", nowMs() - start))
    return false
  end

  app:activate(true)
  local frontApp = hs.application.frontmostApplication()
  if frontApp and frontApp:bundleID() == "com.google.Chrome" then
    traceChromeCycle(string.format("activateChrome hs.activate %.1fms", nowMs() - start))
    return true
  end

  local ok = hs.osascript.applescript([[tell application "Google Chrome" to activate]])
  frontApp = hs.application.frontmostApplication()
  local focused = frontApp and frontApp:bundleID() == "com.google.Chrome"
  traceChromeCycle(string.format(
    "activateChrome applescript ok=%s focused=%s %.1fms",
    tostring(ok),
    tostring(focused),
    nowMs() - start
  ))
  return focused
end

local function chromeIsFrontmost()
  local app = hs.application.frontmostApplication()
  return app and app:bundleID() == "com.google.Chrome"
end

local function focusedChromeWindowMatches(target)
  local frontApp = hs.application.frontmostApplication()
  local focusedWindow = hs.window.focusedWindow()
  local focusedApp = focusedWindow and focusedWindow:application()

  local matches = frontApp
    and frontApp:bundleID() == "com.google.Chrome"
    and focusedApp
    and focusedApp:bundleID() == "com.google.Chrome"
    and titleMatchesWindow(target.title, focusedWindow:title())

  traceChromeCycle(string.format(
    "focusedChromeWindowMatches=%s focusedWin=%s",
    tostring(matches),
    focusedWindow and focusedWindow:title() or "nil"
  ))
  return matches, focusedWindow
end

local function chromePidSet()
  local pids = {}
  for _, app in ipairs(hs.application.runningApplications()) do
    if app:bundleID() == "com.google.Chrome" then
      pids[app:pid()] = true
    end
  end
  return pids
end

local function nearlyEqual(a, b)
  return math.abs((a or 0) - (b or 0)) <= 2
end

local function boundsKey(bounds)
  if not bounds then
    return nil
  end

  return table.concat({
    tostring(math.floor(bounds.x + 0.5)),
    tostring(math.floor(bounds.y + 0.5)),
    tostring(math.floor(bounds.w + 0.5)),
    tostring(math.floor(bounds.h + 0.5)),
  }, ",")
end

local function markAmbiguousBounds(snapshot)
  local counts = {}
  for _, win in ipairs(snapshot.windows) do
    local key = boundsKey(win.bounds)
    win.boundsKey = key
    if key then
      counts[key] = (counts[key] or 0) + 1
    end
  end

  for _, win in ipairs(snapshot.windows) do
    win.ambiguousBounds = win.boundsKey and counts[win.boundsKey] > 1
  end
end

local function clearChromeHighlight()
  if activeChromeHighlight then
    activeChromeHighlight:delete()
    activeChromeHighlight = nil
  end
end

local function showChromeHighlightForFrame(frame)
  if not frame or frame.w <= 0 or frame.h <= 0 then
    return
  end

  local start = nowMs()
  clearChromeHighlight()

  local strokeWidth = 9
  local inset = strokeWidth / 2
  local canvas = hs.canvas.new({
    x = frame.x,
    y = frame.y,
    w = frame.w,
    h = frame.h,
  })
  if not canvas then
    return
  end

  activeChromeHighlight = canvas
  canvas:level(hs.canvas.windowLevels.overlay or hs.canvas.windowLevels.floating)
  canvas:behavior({"canJoinAllSpaces", "fullScreenAuxiliary", "transient"})
  canvas:clickActivating(false)
  canvas:appendElements({
    {
      type = "rectangle",
      action = "stroke",
      frame = {
        x = inset,
        y = inset,
        w = frame.w - strokeWidth,
        h = frame.h - strokeWidth,
      },
      strokeWidth = strokeWidth,
      strokeColor = {red = 1.0, green = 0.05, blue = 0.02, alpha = 0.98},
      antialias = true,
    },
  })
  canvas:show()
  traceChromeCycle(string.format("showChromeHighlightForFrame %.1fms", nowMs() - start))

  hs.timer.doAfter(0.45, function()
    if activeChromeHighlight == canvas then
      clearChromeHighlight()
    else
      canvas:delete()
    end
  end)
end

local function showChromeHighlightForWindow(win)
  if not win then
    return
  end

  hs.timer.doAfter(0.08, function()
    showChromeHighlightForFrame(win:frame())
  end)
end

local chromeWindowIdByBounds

local function showChromeHighlightForTarget(target)
  if not target then
    return
  end

  if not target.ambiguousBounds then
    local windowId = chromeWindowIdByBounds(target.bounds)
    if windowId then
      local win = hs.window.get(windowId)
      if win then
        showChromeHighlightForWindow(win)
        return
      end
    end
  end

  if target.bounds then
    hs.timer.doAfter(0.08, function()
      showChromeHighlightForFrame(target.bounds)
    end)
  end
end

chromeWindowIdByBounds = function(bounds)
  if not bounds then
    return nil
  end

  local start = nowMs()
  for _, info in ipairs(hs.window.list(true) or {}) do
    local cgBounds = info.kCGWindowBounds
    if info.kCGWindowOwnerName == "Google Chrome"
      and info.kCGWindowLayer == 0
      and cgBounds
      and nearlyEqual(cgBounds.X, bounds.x)
      and nearlyEqual(cgBounds.Y, bounds.y)
      and nearlyEqual(cgBounds.Width, bounds.w)
      and nearlyEqual(cgBounds.Height, bounds.h)
    then
      traceChromeCycle(string.format(
        "chromeWindowIdByBounds hit id=%s %.1fms",
        tostring(info.kCGWindowNumber),
        nowMs() - start
      ))
      return info.kCGWindowNumber
    end
  end

  traceChromeCycle(string.format("chromeWindowIdByBounds miss %.1fms", nowMs() - start))
  return nil
end

local function focusTargetViaExactWindow(target)
  if target.ambiguousBounds then
    traceChromeCycle("focusTargetViaExactWindow skipped ambiguous bounds")
    return false
  end

  local windowId = chromeWindowIdByBounds(target.bounds)
  if not windowId then
    return false
  end

  local getStart = nowMs()
  local win = hs.window.get(windowId)
  traceChromeCycle(string.format(
    "focusTargetViaExactWindow hs.window.get id=%s %.1fms",
    tostring(windowId),
    nowMs() - getStart
  ))
  if not win then
    traceChromeCycle("focusTargetViaExactWindow hs.window.get miss id=" .. tostring(windowId))
    return false
  end

  local start = nowMs()
  win:focus()
  showChromeHighlightForWindow(win)
  traceChromeCycle(string.format(
    "focusTargetViaExactWindow id=%s focus issued %.1fms",
    tostring(windowId),
    nowMs() - start
  ))
  return true
end

local function pidFieldHasChrome(pidField, pids)
  if type(pidField) == "table" then
    for _, pid in ipairs(pidField) do
      if pids[pid] then
        return true
      end
    end
    return false
  end
  return pids[pidField] == true
end

local function chromeFullscreenSpaces()
  local start = nowMs()
  local spaces = {}
  local pids = chromePidSet()
  traceChromeCycle(string.format("chromePidSet %.1fms", nowMs() - start))

  for _, display in ipairs(hs.spaces.data_managedDisplaySpaces() or {}) do
    for order, space in ipairs(display.Spaces or {}) do
      if space.type == 4 and pidFieldHasChrome(space.pid, pids) then
        spaces[#spaces + 1] = {
          display = display["Display Identifier"],
          order = order,
          spaceId = space.ManagedSpaceID,
          windowId = space.fs_wid,
        }
      end
    end
  end

  table.sort(spaces, function(a, b)
    if a.display == b.display then
      return a.order < b.order
    end
    return a.display < b.display
  end)

  traceChromeCycle(string.format("chromeFullscreenSpaces count=%d %.1fms", #spaces, nowMs() - start))
  return spaces
end

local function reconcileChromeCycleOrder(snapshot)
  local byId = {}
  local kept = {}
  local nextOrder = {}

  for _, win in ipairs(snapshot.windows) do
    byId[win.id] = win
  end

  for _, id in ipairs(chromeCycleOrder) do
    if byId[id] then
      nextOrder[#nextOrder + 1] = id
      kept[id] = true
    end
  end

  for _, win in ipairs(snapshot.windows) do
    if not kept[win.id] then
      nextOrder[#nextOrder + 1] = win.id
      kept[win.id] = true
    end
  end

  chromeCycleOrder = nextOrder
  traceChromeCycle("cycle order size=" .. tostring(#chromeCycleOrder))
  return byId
end

local function indexOfWindowId(order, id)
  for i, candidate in ipairs(order) do
    if candidate == id then
      return i
    end
  end
  return nil
end

local function focusTargetViaMenuOnce(target)
  local ok = selectChromeWindow(target.title)
  if not ok then
    return false
  end

  activateChrome()

  local focusedMatches, focusedWindow = focusedChromeWindowMatches(target)
  if focusedMatches then
    showChromeHighlightForWindow(focusedWindow)
    return true
  end

  if chromeFrontWindowId() == target.id and chromeIsFrontmost() then
    showChromeHighlightForTarget(target)
    return true
  end

  return false
end

local function focusTargetViaMenuWithRetries(target)
  if focusTargetViaMenuOnce(target) then
    return true
  end

  hs.timer.usleep(fastRetryDelay * 1000000)
  traceChromeCycle("fast retry after menu")
  if focusTargetViaMenuOnce(target) then
    return true
  end

  hs.timer.usleep(slowRetryDelay * 1000000)
  traceChromeCycle("slow retry after menu")
  return focusTargetViaMenuOnce(target)
end

local function gotoSpace(spaceId)
  local start = nowMs()
  local ok, err = hs.spaces.gotoSpace(spaceId)
  traceChromeCycle(string.format("hs.spaces.gotoSpace space=%s ok=%s %.1fms", tostring(spaceId), tostring(ok), nowMs() - start))
  return ok, err
end

local function focusTargetViaFullscreenSpaces(target)
  local spaces = chromeFullscreenSpaces()
  if #spaces == 0 then
    return false
  end

  local focusedSpace = hs.spaces.focusedSpace()
  local startIndex = 1
  for i, space in ipairs(spaces) do
    if space.spaceId == focusedSpace then
      startIndex = i
      break
    end
  end

  for offset = 1, #spaces do
    local idx = ((startIndex + offset - 1) % #spaces) + 1
    local space = spaces[idx]
    traceChromeCycle("fullscreen scan path idx=" .. tostring(idx) .. " space=" .. tostring(space.spaceId))
    local ok = gotoSpace(space.spaceId)
    if ok then
      hs.timer.usleep(80000)
      if focusTargetViaExactWindow(target) then
        return true
      end

      if focusTargetViaMenuWithRetries(target) then
        return true
      end
    end
  end

  return false
end

function cycleChromeWindow()
  startChromeCycleTrace()
  traceChromeCycle("cycleChromeWindow begin")

  local snapshot, snapshotErr = chromeWindowSnapshot()
  if not snapshot then
    hs.alert.show("Cannot read Chrome windows: " .. tostring(snapshotErr))
    finishChromeCycleTrace("finish snapshot failed")
    return
  end

  markAmbiguousBounds(snapshot)

  if snapshot.count < 2 or #snapshot.windows < 2 then
    hs.alert.show("Chrome has " .. tostring(snapshot.count) .. " window")
    finishChromeCycleTrace("finish not enough windows")
    return
  end

  local byId = reconcileChromeCycleOrder(snapshot)
  local currentIndex = indexOfWindowId(chromeCycleOrder, snapshot.frontId) or 0
  local targetIndex = (currentIndex % #chromeCycleOrder) + 1
  local target = byId[chromeCycleOrder[targetIndex]]

  if not target then
    hs.alert.show("Cannot find next Chrome window")
    finishChromeCycleTrace("finish target missing")
    return
  end

  traceChromeCycle(string.format(
    "target index=%d id=%s title=%s",
    targetIndex,
    target.id,
    target.title
  ))

  if focusTargetViaExactWindow(target) then
    finishChromeCycleTrace("finish exact window")
    return
  end

  if focusTargetViaMenuOnce(target) then
    finishChromeCycleTrace("finish menu direct")
    return
  end

  traceChromeCycle("direct menu path did not focus target; trying fullscreen spaces")
  if focusTargetViaFullscreenSpaces(target) then
    finishChromeCycleTrace("finish fullscreen spaces")
    return
  end

  print("Cannot focus Chrome window: " .. target.title)
  finishChromeCycleTrace("finish failed")
end

hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "c", function()
  cycleChromeWindow()
end)

function chromeWindowReport()
  local lines = {}
  local snapshot = chromeWindowSnapshot()
  lines[#lines + 1] = "Chrome AppleScript windows:"
  if snapshot then
    lines[#lines + 1] = "  frontId=" .. tostring(snapshot.frontId)
    for i, win in ipairs(snapshot.windows) do
      lines[#lines + 1] = string.format("  %d. id=%s title=%s", i, win.id, win.title)
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Chrome fullscreen Spaces:"
  for _, space in ipairs(chromeFullscreenSpaces()) do
    lines[#lines + 1] = string.format(
      "  display=%s space=%s window=%s",
      tostring(space.display),
      tostring(space.spaceId),
      tostring(space.windowId)
    )
  end

  return table.concat(lines, "\n")
end

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "v", function()
  local report = chromeWindowReport()
  print(report)
  hs.alert.show(report ~= "" and report or "No Chrome windows seen")
end)
