
-------------------------------------------------------------------------------
-- real configuration
-------------------------------------------------------------------------------
-- variable config
hs.application.enableSpotlightForNameSearches(true)

local mash = {"cmd", "shift", "ctrl"}

hotkeys = {}
hotkeys[","] = "System Preferences"
hotkeys["\\"] = "1Password 7"
hotkeys["="] = ""
hotkeys["A"] = ""
hotkeys["B"] = ""
hotkeys["C"] = "Fantastical 2"
hotkeys["D"] = ""
hotkeys["E"] = "Evernote"
hotkeys["F"] = ""
hotkeys["G"] = ""
hotkeys["H"] = ""
hotkeys["I"] = ""
hotkeys["J"] = ""
hotkeys["K"] = ""
hotkeys["L"] = ""
hotkeys["M"] = "Spark"
hotkeys["N"] = ""
hotkeys["O"] = ""
hotkeys["P"] = "MindNode"
hotkeys["Q"] = ""
-- hotkeys["R"] = "" -- already setting in init.lua
hotkeys["S"] = ""
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
