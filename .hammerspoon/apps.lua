
-------------------------------------------------------------------------------
-- real configuration
-------------------------------------------------------------------------------
-- variable config
hs.window.animationDuration = 0

local mash = {"cmd", "shift", "ctrl"}

hotkeys = {}
-- launch and focus applications with below shortkey
hotkeys["a"] = function() toggle_application("Atom") end
hotkeys["c"] = function() toggle_application("Fantastical 2") end
hotkeys["d"] = function() toggle_application("Dash") end
hotkeys["e"] = function() toggle_application("Evernote") end
hotkeys["h"] = function() toggle_application("MoneyWiz Premium") end
hotkeys["m"] = function() toggle_application("MindNode") end
hotkeys["p"] = function() toggle_application("System Preferences") end
hotkeys['t'] = function() toggle_application("iTerm2") end

for _hotkey, _fn in pairs(hotkeys) do
    hs.hotkey.bind(mash, _hotkey, _fn)
end

hs.hotkey.bind({"⌘", "⌥"}, "f12", function() hs.caffeinate.lockScreen(); end)

-- functions below

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(_app)
  local app = hs.appfinder.appFromName(_app)
  if not app then
    -- FIXME: This should really launch _app
    hs.application.launchOrFocus(_app)
    hs.alert("Running... " .. _app)
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
    -- todo: focus app
    hs.eventtap.keyStroke({'cmd'}, 'n')
  end
end


-- https://github.com/szymonkaliski/Dotfiles/blob/b5a640336efc9fde1e8048c2894529427746076f/Dotfiles/hammerspoon/init.lua#L411-L440
-- function ext.app.forceLaunchOrFocus(appName)
--   -- first focus with hammerspoon
--   hs.application.launchOrFocus(appName)

--   -- clear timer if exists
--   if ext.cache.launchTimer then ext.cache.launchTimer:stop() end

--   -- wait 500ms for window to appear and try hard to show the window
--   ext.cache.launchTimer = hs.timer.doAfter(0.5, function()
--     local frontmostApp     = hs.application.frontmostApplication()
--     local frontmostWindows = hs.fnutils.filter(frontmostApp:allWindows(), function(win) return win:isStandard() end)

--     -- break if this app is not frontmost (when/why?)
--     if frontmostApp:title() ~= appName then
--       print('Expected app in front: ' .. appName .. ' got: ' .. frontmostApp:title())
--       return
--     end

--     if #frontmostWindows == 0 then
--       -- check if there's app name in window menu (Calendar, Messages, etc...)
--       if frontmostApp:findMenuItem({ 'Window', appName }) then
--         -- select it, usually moves to space with this window
--         frontmostApp:selectMenuItem({ 'Window', appName })
--       else
--         -- otherwise send cmd-n to create new window
--         hs.eventtap.keyStroke({ 'cmd' }, 'n')
--       end
--     end
--   end)
-- end