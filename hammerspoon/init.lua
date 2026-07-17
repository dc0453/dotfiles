-- Enable the Hammerspoon `hs` command-line client.
require("hs.ipc")

-- ======================================= Reload on save
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")



-- ======================================= Load Spoons and .lua files

-- disable // Rounded Corners
-- hs.loadSpoon("RoundedCorners")
-- spoon.RoundedCorners.radius = 8
-- spoon.RoundedCorners:start()

-- disable // Mirow Window Manager
-- hs.loadSpoon("MiroWindowsManager")
-- -- added top and bottom padding at the end of miro's window manager: hs.grid.MARGINY = 40
-- hs.window.animationDuration = 0.3
-- spoon.MiroWindowsManager:bindHotkeys({
--   up = {hyper, "up"},
--   right = {hyper, "right"},
--   down = {hyper, "down"},
--   left = {hyper, "left"},
--   fullscreen = {hyper, "f"}
-- })

-- disable // Mic muter hotkey
-- hs.loadSpoon("MicMute")
-- spoon.MicMute:bindHotkeys({toggle = {{}, "pagedown"}})


--  // resize and move windows with mouse
local SkyRocket = hs.loadSpoon("SkyRocket")
sky = SkyRocket:new({
  -- Which modifiers to hold to move a window?
  moveModifiers = {'ctrl','shift'},

  -- Which modifiers to hold to resize a window?
  resizeModifiers = {'alt', 'shift'},
})

-- // Disabled spoons

-- hs.loadSpoon("ArrangeDesktop")
-- hs.loadSpoon("DeepLTranslate")
-- hs.loadSpoon("HSKeybindings")
-- hs.loadSpoon("Hotkeys")
-- hs.loadSpoon("KSheet")

-- ======================================= Define Hyper
local hyper = {"ctrl", "alt", "cmd"}
-- Caps lock is remapped in Karabiner elements to hyper on hold, alfred toggle (non-us-backslash) on hold
-- https://brettterpstra.com/2017/06/15/a-hyper-key-with-karabiner-elements-full-instructions/
-- ======================================= Switcher
--  // Window switcher
local switcher  = require('switcher')
local windowCycle = require("window_cycle")
-- Alt-B is bound to the switcher dialog for all apps.
-- Alt-shift-B is bound to the switcher dialog for the current app.

-- Hyper + "app key" launches/switches to the window of the app or cycles through its open windows if already focused
  -- switcherfunc() cycles through all widows of the frontmost app.
-- Hyper + tab cycles to the previously focused app.

--  function to either open apps or switch through them using switcher
function openswitch(name)
    return function()
        if hs.application.frontmostApplication():name() == name then
          switcherfunc()
        else
          hs.application.launchOrFocus(name)
        end
    end
end

hs.hotkey.bind(hyper, "Z", openswitch("zoom.us"))
-- hs.hotkey.bind(hyper, "C", openswitch("Google Chrome"))
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "p", windowCycle("CatPaw IDE"))
hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "c", windowCycle("Google Chrome"))
-- hs.hotkey.bind(hyper, "v", windowCycle.report("Google Chrome"))


-- ======================================= Utilities
-- // disable window animations
hs.window.animationDuration = 0
