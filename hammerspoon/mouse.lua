-- BetterSnapTool처럼 수정키를 누른 채 마우스를 움직이면(클릭 없이) 창을 이동/크기 조절한다.
--   ⌘ + ⇧ + 마우스 이동: 창 이동
--   ⌘ + ⌃ + 마우스 이동: 크기 조절 (마우스에 가까운 모서리 기준)
--
-- 빠르게 하기 위한 처리
--   * 마우스 이벤트 탭은 정확히 그 수정키 조합을 누른 동안만 켠다
--   * 창은 마우스 아래 접근성 요소에서 바로 찾는다 (모든 창을 순회하지 않음)
--   * 이벤트마다 창을 옮기지 않고, 시작점 기준 목표 위치만 계산해 최대 60fps로 적용한다

local MOVE_MODS   = { cmd = true, shift = true }
local RESIZE_MODS = { cmd = true, ctrl = true }
local INTERVAL_NS = 1e9 / 60
local MIN_SIZE    = 200

local types = hs.eventtap.event.types

local function flagsEqual(flags, mods)
    for _, k in ipairs({ "cmd", "alt", "shift", "ctrl" }) do
        if (flags[k] or false) ~= (mods[k] or false) then return false end
    end
    return true
end

local function windowUnderMouse()
    local pos = hs.mouse.absolutePosition()
    local ok, win = pcall(function()
        local elem = hs.axuielement.systemElementAtPosition(pos)
        if not elem then return nil end
        if elem:attributeValue("AXRole") ~= "AXWindow" then
            elem = elem:attributeValue("AXWindow")
        end
        return elem and elem:asHSWindow()
    end)
    if ok and win and win:isStandard() then return win end

    -- 접근성 요소로 못 찾는 앱용 (느리지만 드묾)
    return hs.fnutils.find(hs.window.orderedWindows(), function(w)
        return hs.geometry(pos):inside(w:frame())
    end)
end

local state = {}   -- mode, win, startMouse, startFrame, corner, pending, lastApply

local function apply()
    local s = state
    if not (s.win and s.pending) then return end
    if s.mode == "move" then
        s.win:setTopLeft(s.pending)
    else
        s.win:setFrame(s.pending, 0)
    end
    s.pending = nil
    s.lastApply = hs.timer.absoluteTime()
end

local function onMouseMoved()
    local s, p = state, hs.mouse.absolutePosition()

    if not s.win then
        s.win = windowUnderMouse()
        if not s.win then return false end
        s.startMouse, s.startFrame = p, s.win:frame()
        local f = s.startFrame
        s.corner = { left = p.x < f.x + f.w / 2, top = p.y < f.y + f.h / 2 }
    end

    local dx, dy = p.x - s.startMouse.x, p.y - s.startMouse.y
    local f = s.startFrame

    if s.mode == "move" then
        s.pending = { x = f.x + dx, y = f.y + dy }
    else
        local w = math.max(MIN_SIZE, s.corner.left and f.w - dx or f.w + dx)
        local h = math.max(MIN_SIZE, s.corner.top  and f.h - dy or f.h + dy)
        local x = s.corner.left and f.x + f.w - w or f.x
        local y = s.corner.top  and f.y + f.h - h or f.y
        s.pending = hs.geometry.rect(x, y, w, h)
    end

    if hs.timer.absoluteTime() - s.lastApply >= INTERVAL_NS then apply() end
    return false
end

-- 전역에 둬야 가비지 컬렉션으로 탭이 멈추지 않는다
mouseWindowMouseTap = hs.eventtap.new({ types.mouseMoved }, onMouseMoved)

mouseWindowFlagsTap = hs.eventtap.new({ types.flagsChanged }, function(e)
    local flags = e:getFlags()
    local mode = (flagsEqual(flags, MOVE_MODS) and "move")
              or (flagsEqual(flags, RESIZE_MODS) and "resize")
              or nil

    if mode ~= state.mode then
        mouseWindowMouseTap:stop()
        apply()   -- 키를 뗀 시점의 마지막 위치 반영
        state = { mode = mode, lastApply = 0 }
        if mode then mouseWindowMouseTap:start() end
    end
    return false
end):start()

-- 마우스 6번째 버튼(index 5): Mission Control
mouseButtonTap = hs.eventtap.new({ types.otherMouseDown }, function(e)
    if e:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) == 5 then
        hs.spaces.toggleMissionControl()
        return true
    end
    return false
end):start()
