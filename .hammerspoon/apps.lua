
-------------------------------------------------------------------------------
-- real configuration
-------------------------------------------------------------------------------
-- variable config
hs.window.animationDuration = 0
hs.application.enableSpotlightForNameSearches(true)

local mash = {"cmd", "shift", "ctrl"}

hotkeys = {}
-- launch and focus applications with below shortkey
-- hotkeys["a"] = function() toggle_application("Atom") end
-- hotkeys["c"] = function() toggle_application("Fantastical 2") end
-- hotkeys["d"] = function() toggle_application("Dash") end
-- hotkeys["e"] = function() toggle_application("Evernote") end
-- hotkeys["h"] = function() toggle_application("MoneyWiz Premium") end
-- hotkeys["m"] = function() toggle_application("MindNode") end
-- hotkeys["p"] = function() toggle_application("System Preferences") end
-- hotkeys['t'] = function() toggle_application("iTerm2") end

hotkeys[","] = "System Preferences"
hotkeys["\\"] = "1Password"
hotkeys["="] = "Things"
hotkeys["A"] = ""
hotkeys["B"] = ""
hotkeys["C"] = "Fantastical 2"
hotkeys["D"] = "Dash"
hotkeys["E"] = ""
hotkeys["F"] = ""
hotkeys["G"] = ""
hotkeys["H"] = "MoneyWiz Premium"
hotkeys["I"] = ""
hotkeys["J"] = ""
hotkeys["K"] = ""
hotkeys["L"] = "Miya Translate"
hotkeys["M"] = "Spark"
hotkeys["N"] = "Evernote"
hotkeys["O"] = ""
hotkeys["P"] = "MindNode"
hotkeys["Q"] = ""
-- hotkeys["R"] = "" -- reload conf
hotkeys["S"] = "Quiver"
hotkeys["T"] = "iTerm2"
hotkeys["U"] = ""
hotkeys["V"] = ""
hotkeys["W"] = ""
hotkeys["X"] = ""
hotkeys["Y"] = ""
hotkeys["Z"] = ""

-- setting toggle application hotkeys
for _hotkey, _app in pairs(hotkeys) do
  if _app ~= nil and _app ~= "" then
    hs.hotkey.bind(mash, _hotkey, function() toggle_application(_app) end)
  end
end

hs.hotkey.bind({"⌘", "⌥"}, "f12", function() hs.caffeinate.lockScreen(); end)

-- functions below

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(_app)
  local app = hs.appfinder.appFromName(_app)
  if not app then
    hs.alert("Running... " .. _app)
    hs.application.launchOrFocus(_app)
    return
  end

  local mainwin = app:mainWindow()
  if mainwin then
    -- toggle it, 
    if mainwin == hs.window.focusedWindow() then
        mainwin:application():hide()
    else
        mainwin:application():activate(true)
        mainwin:application():unhide()
        mainwin:focus()
    end
  else
    -- otherwise send cmd-n to create new window
    if app:isRunning() then
      hs.application.launchOrFocus(_app)
      -- hs.application.launchOrFocusByBundleID(app:bundleID())
      -- hs.eventtap.keyStroke({'cmd'}, 'n')
    end
  end
end
