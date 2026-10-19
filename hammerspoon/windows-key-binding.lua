-- Reference: https://gist.github.com/josephholsten/1e17c7418d9d8ec0e783

local hk = require "hs.hotkey"
local wm = require "windows"

local mash = {"ctrl", "alt"}

-- 누르고 있으면 반복 실행
local function bind_repeat(key, fn)
    hk.bind(mash, key, fn, nil, fn)
end

hk.bind(mash, "return", wm.maximize)
hk.bind(mash, "delete", wm.snapback)
hk.bind(mash, "c", wm.move_to_center)
hk.bind(mash, "m", function() wm.move_to_center_relative({ w = 0.75, h = 0.75 }) end)

hk.bind(mash, "h", wm.move_half_window_to_left)
hk.bind(mash, "l", wm.move_half_window_to_right)
hk.bind(mash, "k", wm.move_half_window_to_up)
hk.bind(mash, "j", wm.move_half_window_to_down)

bind_repeat("left", wm.move_window_to_left)
bind_repeat("right", wm.move_window_to_right)
bind_repeat("up", wm.move_window_to_up)
bind_repeat("down", wm.move_window_to_down)

bind_repeat("-", wm.size_down)
bind_repeat("=", wm.size_up)
bind_repeat("q", wm.size_down_vertical)
bind_repeat("s", wm.size_up_vertical)
bind_repeat("a", wm.size_down_horizontal)
bind_repeat("w", wm.size_up_horizontal)

hk.bind(mash, "n", wm.send_window_next_monitor)

-- Grid mode: 1~6 dispatched by current grid mode
for i = 1, 6 do
    hk.bind(mash, tostring(i), function() wm.move_to_grid_slot(i) end)
end
hk.bind(mash, "`", wm.toggle_grid_mode)

hk.bind(mash, "tab", hs.spaces.toggleMissionControl)
