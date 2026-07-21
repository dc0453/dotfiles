-- Generic application window cycler.
--
-- Usage:
--   local windowCycle = require("window_cycle")
--   hs.hotkey.bind(modifiers, key, windowCycle("Google Chrome"))
--   hs.hotkey.bind(modifiers, reportKey, windowCycle.report("Google Chrome"))
--
-- Each returned closure keeps its own application state. Cycling first tries
-- an exact native window, then the app's Window menu, and finally its
-- full-screen Spaces. This preserves Chrome full-screen-window support while
-- still working for applications that expose the same AppleScript interface.
-- When AppleScript window enumeration is unavailable (for example, Electron
-- apps such as CatPaw IDE), it falls back to Hammerspoon's native window list.
-- A short red outline confirms the window selected by a successful cycle.
--
-- Set to true temporarily when diagnosing focus or latency problems. It logs
-- every stage's elapsed time to the Hammerspoon console; leave it false in
-- normal use.
local TRACE_ENABLED = false

local function buildWindowCycle(appName, mode)
  assert(type(appName) == "string" and appName ~= "", "appName is required")

local fastRetryDelay = 0.03
local slowRetryDelay = 0.12
local activeCycleTrace = nil
local cycleOrder = {}
local activeHighlight = nil
local nativeWindowFilter = hs.window.filter.new(appName)
nativeWindowFilter:setSortOrder(hs.window.filter.sortByFocusedLast)
nativeWindowFilter:keepActive()

local function nowMs()
  return hs.timer.absoluteTime() / 1000000
end

local function startCycleTrace()
  if not TRACE_ENABLED then
    activeCycleTrace = nil
    return
  end

  local now = nowMs()
  activeCycleTrace = {
    start = now,
    last = now,
  }
  print("[window-cycle] start")
end

local function traceCycle(label)
  local trace = activeCycleTrace
  if not trace then
    return
  end

  local now = nowMs()
  print(string.format(
    "[window-cycle] +%.1fms total=%.1fms %s",
    now - trace.last,
    now - trace.start,
    label
  ))
  trace.last = now
end

local function finishCycleTrace(label)
  traceCycle(label or "finish")
  activeCycleTrace = nil
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

local function isTargetApplication(application)
  return application and application:name() == appName
end

local function nativeApplicationWindows()
  return nativeWindowFilter:getWindows(hs.window.filter.sortByFocusedLast)
end

local function applicationWindowSnapshot()
  local start = nowMs()
  local ok, result = hs.osascript.applescript(string.format([[
set AppleScript's text item delimiters to linefeed
tell application %q
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
]], appName))
  if not ok then
    traceCycle(string.format("AppleScript applicationWindowSnapshot failed %.1fms", nowMs() - start))
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

  traceCycle(string.format(
    "AppleScript applicationWindowSnapshot count=%d %.1fms",
    snapshot.count,
    nowMs() - start
  ))
  return snapshot, nil
end

local function applicationFrontWindowId()
  local start = nowMs()
  local ok, result = hs.osascript.applescript(string.format([[
tell application %q
  if (count of windows) is 0 then
    return ""
  end if
  return (id of front window) as text
end tell
]], appName))
  if not ok then
    traceCycle(string.format("AppleScript applicationFrontWindowId failed %.1fms", nowMs() - start))
    return nil
  end

  traceCycle(string.format("AppleScript applicationFrontWindowId %.1fms id=%s", nowMs() - start, result))
  return result
end

local function selectApplicationWindow(title)
  local start = nowMs()
  local app = hs.application.find(appName)
  if not app then
    traceCycle(string.format("selectApplicationWindow app missing %.1fms", nowMs() - start))
    return false, appName .. " is not running"
  end

  if app:selectMenuItem({"Window", title}) then
    traceCycle(string.format("selectApplicationWindow success %.1fms", nowMs() - start))
    return true, nil
  end

  traceCycle(string.format("selectApplicationWindow menu missing %.1fms", nowMs() - start))
  return false, appName .. " Window menu item not found"
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

local function activateApplication()
  local start = nowMs()
  local app = hs.application.find(appName)
  if not app then
    traceCycle(string.format("activateApplication app missing %.1fms", nowMs() - start))
    return false
  end

  app:activate(true)
  local frontApp = hs.application.frontmostApplication()
  if isTargetApplication(frontApp) then
    traceCycle(string.format("activateApplication hs.activate %.1fms", nowMs() - start))
    return true
  end

  local ok = hs.osascript.applescript(string.format([[tell application %q to activate]], appName))
  frontApp = hs.application.frontmostApplication()
  local focused = isTargetApplication(frontApp)
  traceCycle(string.format(
    "activateApplication applescript ok=%s focused=%s %.1fms",
    tostring(ok),
    tostring(focused),
    nowMs() - start
  ))
  return focused
end

local function applicationIsFrontmost()
  local app = hs.application.frontmostApplication()
  return isTargetApplication(app)
end

local function focusedApplicationWindowMatches(target)
  local frontApp = hs.application.frontmostApplication()
  local focusedWindow = hs.window.focusedWindow()
  local focusedApp = focusedWindow and focusedWindow:application()

  local matches = frontApp
    and isTargetApplication(frontApp)
    and focusedApp
    and isTargetApplication(focusedApp)
    and titleMatchesWindow(target.title, focusedWindow:title())

  traceCycle(string.format(
    "focusedApplicationWindowMatches=%s focusedWin=%s",
    tostring(matches),
    focusedWindow and focusedWindow:title() or "nil"
  ))
  return matches, focusedWindow
end

local function applicationPidSet()
  local pids = {}
  for _, app in ipairs(hs.application.runningApplications()) do
    if isTargetApplication(app) then
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

local function clearHighlight()
  if activeHighlight then
    activeHighlight:delete()
    activeHighlight = nil
  end
end

local function showHighlightForFrame(frame)
  if not frame or frame.w <= 0 or frame.h <= 0 then
    return
  end

  local start = nowMs()
  clearHighlight()

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

  activeHighlight = canvas
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
  traceCycle(string.format("showHighlightForFrame %.1fms", nowMs() - start))

  hs.timer.doAfter(0.45, function()
    if activeHighlight == canvas then
      clearHighlight()
    else
      canvas:delete()
    end
  end)
end

local function showHighlightForWindow(win)
  if not win then
    return
  end

  hs.timer.doAfter(0.08, function()
    showHighlightForFrame(win:frame())
  end)
end

local applicationWindowIdByBounds

local function showHighlightForTarget(target)
  if not target then
    return
  end

  if not target.ambiguousBounds then
    local windowId = applicationWindowIdByBounds(target.bounds)
    if windowId then
      local win = hs.window.get(windowId)
      if win then
        showHighlightForWindow(win)
        return
      end
    end
  end

  if target.bounds then
    hs.timer.doAfter(0.08, function()
      showHighlightForFrame(target.bounds)
    end)
  end
end

applicationWindowIdByBounds = function(bounds)
  if not bounds then
    return nil
  end

  local start = nowMs()
  for _, info in ipairs(hs.window.list(true) or {}) do
    local cgBounds = info.kCGWindowBounds
    if info.kCGWindowOwnerName == appName
      and info.kCGWindowLayer == 0
      and cgBounds
      and nearlyEqual(cgBounds.X, bounds.x)
      and nearlyEqual(cgBounds.Y, bounds.y)
      and nearlyEqual(cgBounds.Width, bounds.w)
      and nearlyEqual(cgBounds.Height, bounds.h)
    then
      traceCycle(string.format(
        "applicationWindowIdByBounds hit id=%s %.1fms",
        tostring(info.kCGWindowNumber),
        nowMs() - start
      ))
      return info.kCGWindowNumber
    end
  end

  traceCycle(string.format("applicationWindowIdByBounds miss %.1fms", nowMs() - start))
  return nil
end

local function focusTargetViaExactWindow(target)
  if target.ambiguousBounds then
    traceCycle("focusTargetViaExactWindow skipped ambiguous bounds")
    return false
  end

  local windowId = applicationWindowIdByBounds(target.bounds)
  if not windowId then
    return false
  end

  local getStart = nowMs()
  local win = hs.window.get(windowId)
  traceCycle(string.format(
    "focusTargetViaExactWindow hs.window.get id=%s %.1fms",
    tostring(windowId),
    nowMs() - getStart
  ))
  if not win then
    traceCycle("focusTargetViaExactWindow hs.window.get miss id=" .. tostring(windowId))
    return false
  end

  local start = nowMs()
  win:focus()
  showHighlightForWindow(win)
  traceCycle(string.format(
    "focusTargetViaExactWindow id=%s focus issued %.1fms",
    tostring(windowId),
    nowMs() - start
  ))
  return true
end

local function pidFieldHasApplication(pidField, pids)
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

local function applicationFullscreenSpaces()
  local start = nowMs()
  local spaces = {}
  local pids = applicationPidSet()
  traceCycle(string.format("applicationPidSet %.1fms", nowMs() - start))

  for _, display in ipairs(hs.spaces.data_managedDisplaySpaces() or {}) do
    for order, space in ipairs(display.Spaces or {}) do
      if space.type == 4 and pidFieldHasApplication(space.pid, pids) then
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

  traceCycle(string.format("applicationFullscreenSpaces count=%d %.1fms", #spaces, nowMs() - start))
  return spaces
end

local function reconcileCycleOrder(snapshot)
  local byId = {}
  local kept = {}
  local nextOrder = {}

  for _, win in ipairs(snapshot.windows) do
    byId[win.id] = win
  end

  for _, id in ipairs(cycleOrder) do
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

  cycleOrder = nextOrder
  traceCycle("cycle order size=" .. tostring(#cycleOrder))
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
  local ok = selectApplicationWindow(target.title)
  if not ok then
    return false
  end

  activateApplication()

  local focusedMatches, focusedWindow = focusedApplicationWindowMatches(target)
  if focusedMatches then
    showHighlightForWindow(focusedWindow)
    return true
  end

  if applicationFrontWindowId() == target.id and applicationIsFrontmost() then
    showHighlightForTarget(target)
    return true
  end

  return false
end

local function focusTargetViaMenuWithRetries(target)
  if focusTargetViaMenuOnce(target) then
    return true
  end

  hs.timer.usleep(fastRetryDelay * 1000000)
  traceCycle("fast retry after menu")
  if focusTargetViaMenuOnce(target) then
    return true
  end

  hs.timer.usleep(slowRetryDelay * 1000000)
  traceCycle("slow retry after menu")
  return focusTargetViaMenuOnce(target)
end

local function screenByUUID(uuid)
  for _, screen in ipairs(hs.screen.allScreens()) do
    if screen:getUUID() == uuid then
      return screen
    end
  end
  return nil
end

local function focusVisibleWindowOnScreen(screen)
  for _, win in ipairs(hs.window.visibleWindows()) do
    if win:isStandard() and win:screen() == screen then
      win:focus()
      return true
    end
  end
  return false
end

local function gotoSpace(spaceId)
  local start = nowMs()
  local displayUUID, displayErr = hs.spaces.spaceDisplay(spaceId)
  local screen = displayUUID and screenByUUID(displayUUID)
  if not screen then
    traceCycle("native space switch display missing: " .. tostring(displayErr))
    return false, displayErr or "display not found"
  end

  local spaces, spacesErr = hs.spaces.spacesForScreen(screen)
  local activeSpace = hs.spaces.activeSpaceOnScreen(screen)
  local activeIndex = indexOfWindowId(spaces or {}, activeSpace)
  local targetIndex = indexOfWindowId(spaces or {}, spaceId)
  if not activeIndex or not targetIndex then
    traceCycle("native space switch index missing: " .. tostring(spacesErr))
    return false, spacesErr or "space index not found"
  end

  if activeIndex == targetIndex then
    return true
  end

  local direction = targetIndex > activeIndex and 1 or -1
  local keyCode = direction > 0 and 124 or 123
  local maxSteps = #spaces
  local steps = 0

  while activeSpace ~= spaceId and steps < maxSteps do
    if not focusVisibleWindowOnScreen(screen) then
      return false, "no visible window on target display"
    end
    hs.timer.usleep(150000)

    local previousSpace = activeSpace
    local ok, result = hs.osascript.applescript(string.format([[
tell application "System Events" to key code %d using control down
]], keyCode))
    if not ok then
      return false, result
    end

    local deadline = nowMs() + 1500
    repeat
      hs.timer.usleep(50000)
      activeSpace = hs.spaces.activeSpaceOnScreen(screen)
    until activeSpace ~= previousSpace or nowMs() >= deadline

    if activeSpace == previousSpace then
      return false, "space switch timed out"
    end
    steps = steps + 1
  end

  local switched = activeSpace == spaceId
  traceCycle(string.format(
    "native space switch space=%s steps=%d switched=%s %.1fms",
    tostring(spaceId),
    steps,
    tostring(switched),
    nowMs() - start
  ))
  return switched, switched and nil or "target space not reached"
end

local function cycleApplicationFullscreenSpace()
  local spaces = applicationFullscreenSpaces()
  if #spaces < 2 then
    return false
  end

  local focusedWindow = hs.window.focusedWindow()
  local focusedWindowId = focusedWindow and focusedWindow:id()
  local currentIndex = 0
  for i, space in ipairs(spaces) do
    if space.windowId == focusedWindowId then
      currentIndex = i
      break
    end
  end

  local targetIndex = (currentIndex % #spaces) + 1
  local target = spaces[targetIndex]
  traceCycle(string.format(
    "fullscreen cycle target space=%s window=%s",
    tostring(target.spaceId),
    tostring(target.windowId)
  ))

  local targetDisplay = hs.spaces.spaceDisplay(target.spaceId)
  local targetScreen = targetDisplay and screenByUUID(targetDisplay)
  local targetIsVisible = targetScreen
    and hs.spaces.activeSpaceOnScreen(targetScreen) == target.spaceId
  local targetWindow = targetIsVisible and target.windowId and hs.window.get(target.windowId)
  if targetWindow then
    targetWindow:raise():focus()
    showHighlightForWindow(targetWindow)
    return true
  end

  local switched = gotoSpace(target.spaceId)
  if switched then
    local visibleTarget = target.windowId and hs.window.get(target.windowId)
    showHighlightForWindow(visibleTarget)
  end
  return switched
end

local function focusTargetViaFullscreenSpaces(target)
  local spaces = applicationFullscreenSpaces()
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
    traceCycle("fullscreen scan path idx=" .. tostring(idx) .. " space=" .. tostring(space.spaceId))
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

local function cycleNativeWindows()
  local windows = nativeApplicationWindows()
  if #windows == 0 then
    hs.alert.show("Cannot find a visible " .. appName .. " window")
    return false
  end

  -- sortByFocusedLast is MRU-first, so the last window matches the existing
  -- switcherfunc behavior and cycles through the least-recent target.
  local target = windows[#windows]
  target:focus()
  showHighlightForWindow(target)
  traceCycle("native window fallback focused id=" .. tostring(target:id()))
  return true
end

local function cycleWindow()
  startCycleTrace()
  traceCycle("cycleWindow begin")

  local snapshot, snapshotErr = applicationWindowSnapshot()
  if not snapshot then
    traceCycle("AppleScript unavailable; using native windows: " .. tostring(snapshotErr))
    if cycleNativeWindows() then
      finishCycleTrace("finish native fallback")
      return
    end
    finishCycleTrace("finish native fallback failed")
    return
  end

  markAmbiguousBounds(snapshot)

  if snapshot.count < 2 or #snapshot.windows < 2 then
    if cycleApplicationFullscreenSpace() then
      finishCycleTrace("finish fullscreen space cycle")
      return
    end

    hs.application.launchOrFocus(appName)
    finishCycleTrace("finish single window launch or focus")
    return
  end

  local byId = reconcileCycleOrder(snapshot)
  local currentIndex = indexOfWindowId(cycleOrder, snapshot.frontId) or 0
  local targetIndex = (currentIndex % #cycleOrder) + 1
  local target = byId[cycleOrder[targetIndex]]

  if not target then
    hs.alert.show("Cannot find next " .. appName .. " window")
    finishCycleTrace("finish target missing")
    return
  end

  traceCycle(string.format(
    "target index=%d id=%s title=%s",
    targetIndex,
    target.id,
    target.title
  ))

  if focusTargetViaExactWindow(target) then
    finishCycleTrace("finish exact window")
    return
  end

  if focusTargetViaMenuOnce(target) then
    finishCycleTrace("finish menu direct")
    return
  end

  traceCycle("direct menu path did not focus target; trying fullscreen spaces")
  if focusTargetViaFullscreenSpaces(target) then
    finishCycleTrace("finish fullscreen spaces")
    return
  end

  print("Cannot focus " .. appName .. " window: " .. target.title)
  finishCycleTrace("finish failed")
end

local function windowReport()
  local lines = {}
  local snapshot = applicationWindowSnapshot()
  lines[#lines + 1] = appName .. " AppleScript windows:"
  if snapshot then
    lines[#lines + 1] = "  frontId=" .. tostring(snapshot.frontId)
    for i, win in ipairs(snapshot.windows) do
      lines[#lines + 1] = string.format("  %d. id=%s title=%s", i, win.id, win.title)
    end
  else
    lines[#lines + 1] = "  unavailable; using Hammerspoon native windows instead"
    for i, win in ipairs(nativeApplicationWindows()) do
      lines[#lines + 1] = string.format("  %d. id=%s title=%s", i, tostring(win:id()), win:title())
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = appName .. " fullscreen Spaces:"
  for _, space in ipairs(applicationFullscreenSpaces()) do
    lines[#lines + 1] = string.format(
      "  display=%s space=%s window=%s",
      tostring(space.display),
      tostring(space.spaceId),
      tostring(space.windowId)
    )
  end

  return table.concat(lines, "\n")
end

if mode == "report" then
  return function()
    local report = windowReport()
    print(report)
    hs.alert.show(report ~= "" and report or "No " .. appName .. " windows seen")
  end
end

return cycleWindow
end

local windowCycle = setmetatable({}, {
  __call = function(_, appName)
    return buildWindowCycle(appName)
  end,
})

function windowCycle.report(appName)
  return buildWindowCycle(appName, "report")
end

return windowCycle
