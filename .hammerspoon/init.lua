require "apps"

require "windows-key-binding"
require "windows"
--require "window-move-resize-with-mouse"

-------------------------------------------------------------------------------
-- reload configuration
-------------------------------------------------------------------------------
--hs.hotkey.bind({"cmd", "shift", "ctrl"}, "R", function()
-- hs.hotkey.bind({"fn"}, "r", function()
--     hs.reload()
--     print('config reloaded')
-- end)

--hs.hotkey.bind({"cmd", "alt"}, "f12", function() os.execute("pmset displaysleepnow"); end)

-- for debug
local function print_table(t)
    for key, value in pairs(t) do
        print(value:name())
    end
end
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "/", function() print_table(hs.application.runningApplications()); end )

-- VIM support
-- https://johngrib.github.io/blog/2017/05/04/input-source/
-- https://github.com/johngrib/simple_vim_guide/blob/master/md/with_korean.md
-- hs.hotkey.bind({}, "ESCAPE", function()
--     local inputEnglish = "com.apple.keylayout.ABC"
--     local input_source = hs.keycodes.currentSourceID()

--     if not (input_source == inputEnglish) then
--         hs.eventtap.keyStroke({}, 'right')
--         hs.keycodes.currentSourceID(inputEnglish)
--     end
--     hs.eventtap.keyStroke({'control'}, 'c')
-- end)

-- start hammerspoon
hs.alert("Hammerspoon config loaded")