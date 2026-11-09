-- BetterSnapTool처럼 수정키를 누른 채 마우스를 움직이면(클릭 없이) 창을 이동/크기 조절한다.
--   ⌘ + ⇧ + 마우스 이동: 창 이동
--   ⌘ + ⌃ + 마우스 이동: 크기 조절 (왼쪽 위는 고정, 오른쪽→넓게, 아래→길게)
--
-- 빠르게 하기 위한 처리
--   * 마우스 이벤트 탭은 정확히 그 수정키 조합을 누른 동안만 켠다
--   * 창은 화면 창 목록(앞→뒤)에서 마우스 아래 첫 창으로 찾는다 (떠 있는 패널도 잡힌다)
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

-- 화면 창 목록(앞→뒤 순서)에서 마우스 아래 가장 앞 창을 고른다.
-- 접근성 hit-test 와 orderedWindows 는 떠 있는 패널(QuickMermaid 등, subrole AXSystemDialog)을 놓쳐 뒤 창을 잡는다.
-- 레벨 0~19 만 본다: 일반 창(0)·floating(3)·modal(8)·utility(19). Dock(20)·메뉴바(24~25) 등은 제외
local MAX_WINDOW_LAYER = 19

local function windowUnderMouse()
    local pos = hs.mouse.absolutePosition()
    for _, info in ipairs(hs.window.list(false) or {}) do
        local layer, b = info.kCGWindowLayer, info.kCGWindowBounds
        if layer and layer >= 0 and layer <= MAX_WINDOW_LAYER and b
            and pos.x >= b.X and pos.x < b.X + b.Width
            and pos.y >= b.Y and pos.y < b.Y + b.Height then
            local win = hs.window.get(info.kCGWindowNumber)
            if win then return win end
        end
    end
    return nil
end

local state = {}   -- mode, win, startMouse, startFrame, pending, lastApply

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
    end

    local dx, dy = p.x - s.startMouse.x, p.y - s.startMouse.y
    local f = s.startFrame

    if s.mode == "move" then
        s.pending = { x = f.x + dx, y = f.y + dy }
    else
        local w = math.max(MIN_SIZE, f.w + dx)
        local h = math.max(MIN_SIZE, f.h + dy)
        s.pending = hs.geometry.rect(f.x, f.y, w, h)
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
