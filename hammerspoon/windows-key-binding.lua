-- Reference: https://gist.github.com/josephholsten/1e17c7418d9d8ec0e783

local keymap = require "keymap"
local wm = require "windows"

local SECTION = "창 조작"
local mash = {"ctrl", "alt"}

local function bind(key, description, fn)
    keymap.bind(SECTION, mash, key, description, fn)
end

-- 누르고 있으면 반복 실행
local function bind_repeat(key, description, fn)
    keymap.bind(SECTION, mash, key, description, fn, fn)
end

bind("return", "최대화", wm.maximize)
bind("delete", "직전 위치로 되돌리기 (한 번 더 누르면 원위치)", wm.snapback)
bind("c", "가운데로 이동 (크기 유지)", wm.move_to_center)
bind("m", "가운데에 화면 75% 크기로", function() wm.move_to_center_relative({ w = 0.75, h = 0.75 }) end)

bind("h", "왼쪽 절반", wm.move_half_window_to_left)
bind("l", "오른쪽 절반", wm.move_half_window_to_right)
bind("k", "위쪽 절반", wm.move_half_window_to_up)
bind("j", "아래쪽 절반", wm.move_half_window_to_down)

bind_repeat("left", "왼쪽으로 20px 이동", wm.move_window_to_left)
bind_repeat("right", "오른쪽으로 20px 이동", wm.move_window_to_right)
bind_repeat("up", "위로 20px 이동", wm.move_window_to_up)
bind_repeat("down", "아래로 20px 이동", wm.move_window_to_down)

bind_repeat("-", "사방으로 줄이기", wm.size_down)
bind_repeat("=", "사방으로 키우기", wm.size_up)
bind_repeat("q", "높이 줄이기", wm.size_down_vertical)
bind_repeat("s", "높이 늘리기", wm.size_up_vertical)
bind_repeat("a", "너비 줄이기", wm.size_down_horizontal)
bind_repeat("w", "너비 늘리기", wm.size_up_horizontal)

bind("n", "다음 모니터로 보내기", wm.send_window_next_monitor)

-- Grid mode: 1~6 dispatched by current grid mode
for i = 1, 6 do
    bind(tostring(i), "그리드 칸으로 (번호는 왼쪽→오른쪽, 위→아래)", function() wm.move_to_grid_slot(i) end)
end
bind("`", "그리드 모양 바꾸기 (" .. wm.grid_mode_names() .. ")", wm.toggle_grid_mode)

bind("tab", "Mission Control", hs.spaces.toggleMissionControl)
