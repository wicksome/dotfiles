-- Reference: https://gist.github.com/josephholsten/1e17c7418d9d8ec0e783

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

hk.bind(mash, "h", wm.move_half_window_to_left)
hk.bind(mash, "l", wm.move_half_window_to_right)
hk.bind(mash, "k", wm.move_half_window_to_up)
hk.bind(mash, "j", wm.move_half_window_to_down)

hk.bind(mash, "y", wm.move_window_to_left, nil, wm.move_window_to_left)
hk.bind(mash, "o", wm.move_window_to_right, nil, wm.move_window_to_right)
hk.bind(mash, "i", wm.move_window_to_up, nil, wm.move_window_to_up)
hk.bind(mash, "u", wm.move_window_to_down, nil, wm.move_window_to_down)

-- (mash, key, 눌렀을 때, 놓았을 때, 눌린 상태)
hk.bind(mash, "[", wm.size_down, nil, wm.size_down)
hk.bind(mash, "]", wm.size_up, nil, wm.size_up)

hk.bind(mash, "left", wm.send_window_prev_monitor)
hk.bind(mash, "right", wm.send_window_next_monitor)

hk.bind(mash, "1", wm.move_window_upper_left)
hk.bind(mash, "2", wm.move_window_upper_right)
hk.bind(mash, "3", wm.move_window_lower_left)
hk.bind(mash, "4", wm.move_window_lower_right)
