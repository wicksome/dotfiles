require "windows"
require "windows-key-binding"

require "apps-shortcut"
require "mouse"
require "keyboard"
--require "window-move-resize-with-mouse"

-- for debug
local function print_table(t)
    for key, value in pairs(t) do
        print(value:name())
    end
end
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "/", function() print_table(hs.application.runningApplications()); end )

-- start hammerspoon
hs.alert("Hammerspoon config loaded")

doKeyStroke = function(modifiers, character)
    local event = require("hs.eventtap").event
    event.newKeyEvent(modifiers, string.lower(character), true):post()
    event.newKeyEvent(modifiers, string.lower(character), false):post()
end


-- ref: https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org

-- TODO
-- btn5: Mission Control
-- ^ + scroll right: Move left a space
-- ^ + scroll left: Move right a space
-- button4: Middle Click
-- shift, ctfl, cmd, ` : Show Notification Center

-- BTT
-- Moving & Resizing Modifier Keys
-- shift, cmd: move
-- ctrl, cmd: resize
-- pixel: 2


-- https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org#clipboard-history
-- https://github.com/asmagill/hs._asm.undocumented.spaces