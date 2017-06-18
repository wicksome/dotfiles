mash = {"⌘", "⇧", "⌃"} -- ⌘ ⌥ ⌃ ⇧

require "apps"
--require "grid"

hs.hotkey.bind(mash, "r", function() hs.reload(); end)
hs.hotkey.bind({"⌘", "⌥"}, "f10", function() hs.caffeinate.startScreensaver(); end)
hs.hotkey.bind({"⌘", "⌥"}, "f11", function() hs.caffeinate.systemSleep(); end)
hs.hotkey.bind({"⌘", "⌥"}, "f12", function() hs.caffeinate.lockScreen(); end)
hs.alert("Hammerspoon config loaded")
