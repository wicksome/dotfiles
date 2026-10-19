local M = {}

local STEP = 20 -- px, 이동/크기 조절 단위

hs.window.animationDuration = 0

----------------
-- Helpers    --
----------------

-- 창 id별 직전 위치 (snapback용)
local snapback_state = {}

local function focused()
    local win = hs.window.focusedWindow()
    if not win then hs.alert("No focused window") end
    return win
end

-- 레이아웃 이동(반쪽/그리드/최대화 등): 되돌릴 수 있도록 직전 위치를 저장한다
local function place(win, frame)
    snapback_state[win:id()] = win:frame()
    win:setFrame(frame)
end

-- 화면 기준 비율 rect(0~1)로 배치
local function place_unit(x, y, w, h)
    local win = focused()
    if not win then return end
    local s = win:screen():frame()
    place(win, { x = s.x + s.w * x, y = s.y + s.h * y, w = s.w * w, h = s.h * h })
end

-- 현재 frame 기준 상대 조정. 키를 누르고 있으면 반복되므로 snapback에 저장하지 않는다
local function nudge(dx, dy, dw, dh)
    return function()
        local win = focused()
        if not win then return end
        local f = win:frame()
        win:setFrame({ x = f.x + dx, y = f.y + dy, w = f.w + dw, h = f.h + dh })
    end
end

----------------
-- Public API --
----------------

M.maximize = function() place_unit(0, 0, 1, 1) end

M.move_half_window_to_left  = function() place_unit(0, 0, 0.5, 1) end
M.move_half_window_to_right = function() place_unit(0.5, 0, 0.5, 1) end
M.move_half_window_to_up    = function() place_unit(0, 0, 1, 0.5) end
M.move_half_window_to_down  = function() place_unit(0, 0.5, 1, 0.5) end

M.move_to_center_relative = function(size)
    place_unit((1 - size.w) / 2, (1 - size.h) / 2, size.w, size.h)
end

M.move_to_center = function()
    local win = focused()
    if not win then return end
    local f, s = win:frame(), win:screen():frame()
    place(win, { x = s.x + (s.w - f.w) / 2, y = s.y + (s.h - f.h) / 2, w = f.w, h = f.h })
end

M.move_window_to_left  = nudge(-STEP, 0, 0, 0)
M.move_window_to_right = nudge(STEP, 0, 0, 0)
M.move_window_to_up    = nudge(0, -STEP, 0, 0)
M.move_window_to_down  = nudge(0, STEP, 0, 0)

M.size_up              = nudge(-STEP / 2, -STEP / 2, STEP, STEP)
M.size_down            = nudge(STEP / 2, STEP / 2, -STEP, -STEP)
M.size_up_vertical     = nudge(0, 0, 0, STEP)
M.size_down_vertical   = nudge(0, 0, 0, -STEP)
M.size_up_horizontal   = nudge(0, 0, STEP, 0)
M.size_down_horizontal = nudge(0, 0, -STEP, 0)

-- 직전 위치로 되돌린다. 두 번 호출하면 원래 위치로 돌아온다
M.snapback = function()
    local win = focused()
    if not win then return end
    local prev = snapback_state[win:id()]
    snapback_state[win:id()] = win:frame()
    if prev then win:setFrame(prev) end
end

M.send_window_next_monitor = function()
    local win = focused()
    if not win then return end
    hs.alert.show("Next Monitor")
    -- 내장 moveToScreen이 상대 위치/크기를 유지한다
    win:moveToScreen(win:screen():next())
end

-- Grid mode --

local grid_modes = {
    { name = "quad", cols = 2, rows = 2, label = "┌──┬──┐\n│1 │2 │\n├──┼──┤\n│3 │4 │\n└──┴──┘" },
    { name = "3x2",  cols = 3, rows = 2, label = "┌──┬──┬──┐\n│1 │2 │3 │\n├──┼──┼──┤\n│4 │5 │6 │\n└──┴──┴──┘" },
    { name = "2x3",  cols = 2, rows = 3, label = "┌──┬──┐\n│1 │2 │\n├──┼──┤\n│3 │4 │\n├──┼──┤\n│5 │6 │\n└──┴──┘" },
    { name = "3x1",  cols = 3, rows = 1, label = "┌──┬──┬──┐\n│1 │2 │3 │\n└──┴──┴──┘" },
    { name = "1x3",  cols = 1, rows = 3, label = "┌──┐\n│1 │\n├──┤\n│2 │\n├──┤\n│3 │\n└──┘" },
}
local grid_index = 1
local grid_alert_style = { textFont = "Menlo", textSize = 24 }
local grid_alert_uuid = nil

-- 슬롯 번호는 왼쪽→오른쪽, 위→아래 순서
M.move_to_grid_slot = function(slot)
    local g = grid_modes[grid_index]
    if slot > g.cols * g.rows then return end
    local col, row = (slot - 1) % g.cols, (slot - 1) // g.cols
    place_unit(col / g.cols, row / g.rows, 1 / g.cols, 1 / g.rows)
end

M.toggle_grid_mode = function()
    grid_index = grid_index % #grid_modes + 1
    if grid_alert_uuid then hs.alert.closeSpecific(grid_alert_uuid) end
    grid_alert_uuid = hs.alert.show(grid_modes[grid_index].label, grid_alert_style, 1)
end

return M
