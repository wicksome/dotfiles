local hk = require "hs.hotkey"
local wm = require "windows"

local mash = {"ctrl", "alt"}


hk.bind(mash, "return", wm.maximize)
hk.bind(mash, "delete", wm.snapback)
hk.bind(mash, "c", wm.move_to_center)
hk.bind(mash, "w", function ()
    -- wm.move_to_center_absolute({w = 800, h = 600})
    wm.move_to_center_relative({w = 0.75, h = 0.75})
end)

hk.bind(mash, "h", wm.send_window_left)
hk.bind(mash, "l", wm.send_window_right)
hk.bind(mash, "k", wm.send_window_up)
hk.bind(mash, "j", wm.send_window_down)

hk.bind(mash, "[", wm.size_down)
hk.bind(mash, "]", wm.size_up)
