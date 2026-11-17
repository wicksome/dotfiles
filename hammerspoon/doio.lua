-- DOIO KB16B-02 매크로 패드 입력을 가로채 동작이나 다른 키로 바꾼다.
-- 패드는 기본 키맵(숫자·방향키·Enter)을 그대로 보내므로, macOS 가 키 이벤트에 붙이는
-- keyboard type 값으로 노트북 키보드(91)와 패드(40)를 구분한다.
-- keyboard type 은 기기 고유 ID 가 아니다. 같은 type 의 외장 키보드를 함께 쓰면 그 입력도 잡힌다.
-- 패드 사용법(B/R 버튼, 유선 전환, VIA json, BT 1대 제한):
-- https://blog.naver.com/cotton_mellow_s2/223348486592
local doio = {}

local DOIO_KEYBOARD_TYPE = 40
-- 이 모듈이 다시 보낸 키 이벤트 표시. 다시 가로채지 않게 한다.
local REMAPPED_EVENT_MARK = 0x444F494F

local types = hs.eventtap.event.types
local properties = hs.eventtap.event.properties

-- 패드 키 이름 → 기본 키맵이 보내는 keycode
-- 배치(왼쪽 위부터 행 순서): 1 2 3 4 / 5 6 7 8 / 9 0 up return / (레이어 키) left down right
-- 왼쪽 아래 레이어 키는 펌웨어가 처리해 맥으로 키 이벤트를 보내지 않는다.
local padKeyCodes = {
    ["1"] = 18, ["2"] = 19, ["3"] = 20, ["4"] = 21,
    ["5"] = 23, ["6"] = 22, ["7"] = 26, ["8"] = 28,
    ["9"] = 25, ["0"] = 29, ["up"] = 126, ["return"] = 36,
    ["left"] = 123, ["down"] = 125, ["right"] = 124,
    -- 오른쪽 작은 노브 회전. 나머지 노브(곡 넘김·볼륨)는 미디어 이벤트라 keyboard type 이 0 이어서 구분할 수 없다.
    ["knobLeft"] = 116, ["knobRight"] = 121,
}

-- keycode → 등록 순서대로의 handler 목록. 조건이 맞는 첫 handler 가 처리한다.
-- handler = { app = bundleID | nil, label = string, down = function(), up = function() | nil, repeats = boolean }
local handlers = {}

local MOD_SYMBOLS = { { "ctrl", "⌃" }, { "alt", "⌥" }, { "shift", "⇧" }, { "cmd", "⌘" } }
local KEY_SYMBOLS = {
    up = "↑", down = "↓", left = "←", right = "→",
    ["return"] = "⏎", delete = "⌫", tab = "⇥", space = "Space", escape = "Esc",
}

-- { "cmd", "shift" }, "[" → "⌘⇧["
local function shortcutLabel(mods, keyName)
    local text = ""
    for _, pair in ipairs(MOD_SYMBOLS) do
        for _, mod in ipairs(mods) do
            if mod == pair[1] then
                text = text .. pair[2]
            end
        end
    end
    return text .. (KEY_SYMBOLS[keyName] or keyName:upper())
end

local function postKey(mods, keyName, isDown)
    local event = hs.eventtap.event.newKeyEvent(keyName, isDown)
    -- 새 이벤트에는 fn 플래그가 붙어 나온다. 그대로 두면 a·c 가 macOS 의 fn+A(Dock)·fn+C(제어 센터)로 먹힌다.
    -- F1~F19 는 실제 키보드처럼 fn 을 붙여야 hs.hotkey 가 받는다. F20 은 fn 이 붙으면 받지 못한다(실측).
    local flags = {}
    for _, mod in ipairs(mods) do
        flags[mod] = true
    end
    local functionKeyNumber = tonumber(keyName:match("^f(%d+)$"))
    if functionKeyNumber and functionKeyNumber <= 19 then
        flags.fn = true
    end
    event:setFlags(flags)
    event:setProperty(properties.eventSourceUserData, REMAPPED_EVENT_MARK)
    event:post()
end

local function isFromPad(event)
    return event:getProperty(properties.keyboardEventKeyboardType) == DOIO_KEYBOARD_TYPE
        and event:getProperty(properties.eventSourceUserData) ~= REMAPPED_EVENT_MARK
end

-- 앞에 있는 앱. 포커스 창의 앱을 먼저 본다.
-- Claude Code 는 버전 이름(예: 2.1.316)의 번들 없는 프로세스로 앞 앱 자리를 가져갈 때가 있어,
-- frontmostApplication 만 보면 Orca 매핑이 풀렸다.
local function frontmostApplication()
    local window = hs.window.focusedWindow()
    local app = window and window:application()
    if app and app:bundleID() then
        return app
    end
    return hs.application.frontmostApplication()
end

local function frontmostBundleID()
    local app = frontmostApplication()
    return app and app:bundleID()
end

local function findHandler(keyCode)
    local candidates = handlers[keyCode]
    if not candidates then
        return nil
    end
    local bundleID = frontmostBundleID()
    for _, handler in ipairs(candidates) do
        if handler.app == nil or handler.app == bundleID then
            return handler
        end
    end
    return nil
end

-- keyDown 때 고른 handler. keyUp 사이에 앞 앱이 바뀌어도 같은 handler 로 짝을 맞춘다.
local activeHandlers = {}

doio.tap = hs.eventtap.new({ types.keyDown, types.keyUp }, function(event)
    if not isFromPad(event) then
        return false
    end
    local keyCode = event:getKeyCode()
    if event:getType() == types.keyDown then
        local handler = activeHandlers[keyCode] or findHandler(keyCode)
        if not handler then
            return false
        end
        local isRepeat = event:getProperty(properties.keyboardEventAutorepeat) ~= 0
        if not isRepeat then
            activeHandlers[keyCode] = handler
        end
        if not isRepeat or handler.repeats then
            handler.down()
        end
        return true
    end
    local handler = activeHandlers[keyCode]
    if not handler then
        return false
    end
    activeHandlers[keyCode] = nil
    if handler.up then
        handler.up()
    end
    return true
end)

local function register(name, handler)
    local keyCode = padKeyCodes[name]
    assert(keyCode, "unknown DOIO key: " .. tostring(name))
    -- 앱 조건이 있는 handler 를 앞에 두어 전체 적용 handler 보다 먼저 고른다.
    handlers[keyCode] = handlers[keyCode] or {}
    if handler.app then
        table.insert(handlers[keyCode], 1, handler)
    else
        table.insert(handlers[keyCode], handler)
    end
end

-- 패드 키를 누르면 action 을 한 번 실행한다. options.app 이 있으면 그 앱이 앞에 있을 때만 적용한다.
-- options.label 은 배치 보기 화면에 표시할 이름이다.
function doio.bind(name, action, options)
    options = options or {}
    register(name, { app = options.app, label = options.label or "동작", down = action })
end

-- 패드 키를 다른 키(조합)로 바꿔 보낸다. 누르고 있는 동안의 반복도 그대로 전달한다.
-- options.mods = { "cmd", "shift", ... }, options.app = bundleID
function doio.remap(name, targetKeyName, options)
    options = options or {}
    local mods = options.mods or {}
    assert(hs.keycodes.map[targetKeyName], "unknown target key: " .. tostring(targetKeyName))
    register(name, {
        app = options.app,
        label = options.label or shortcutLabel(mods, targetKeyName),
        down = function() postKey(mods, targetKeyName, true) end,
        up = function() postKey(mods, targetKeyName, false) end,
        repeats = true,
    })
end

-- 미디어 키(곡 넘김·재생·볼륨) → handler 목록.
-- 미디어 이벤트는 keyboard type 이 0 이라 패드와 노트북 키보드를 구분하지 못한다.
-- 그래서 app 조건을 반드시 걸어, 그 앱이 앞에 있을 때만 노트북 미디어 키까지 함께 바꾼다.
local mediaHandlers = {}

doio.mediaTap = hs.eventtap.new({ types.systemDefined }, function(event)
    if event:getProperty(properties.eventSourceUserData) == REMAPPED_EVENT_MARK then
        return false
    end
    local media = event:systemKey()
    local candidates = media.key and mediaHandlers[media.key]
    if not candidates then
        return false
    end
    local bundleID = frontmostBundleID()
    for _, handler in ipairs(candidates) do
        if handler.app == bundleID then
            if media.down then
                -- 탭 콜백 안에서 바로 키를 보내면 콜백이 다시 불리며 스택이 넘쳤다. 다음 실행 주기로 미룬다.
                hs.timer.doAfter(0, handler.down)
            end
            return true
        end
    end
    return false
end)

-- 미디어 키를 누르면 action 을 한 번 실행한다. options.app 은 필수다.
function doio.bindMedia(mediaKey, action, options)
    assert(options and options.app, "bindMedia needs options.app")
    mediaHandlers[mediaKey] = mediaHandlers[mediaKey] or {}
    table.insert(mediaHandlers[mediaKey], { app = options.app, label = options.label or "동작", down = action })
end

-- 미디어 키를 다른 키(조합)로 바꿔 보낸다. options.app 은 필수다.
function doio.remapMedia(mediaKey, targetKeyName, options)
    assert(options and options.app, "remapMedia needs options.app")
    assert(hs.keycodes.map[targetKeyName], "unknown target key: " .. tostring(targetKeyName))
    local mods = options and options.mods or {}
    doio.bindMedia(mediaKey, function()
        postKey(mods, targetKeyName, true)
        postKey(mods, targetKeyName, false)
    end, {
        app = options.app,
        label = options.label or shortcutLabel(mods, targetKeyName),
    })
end

-- 앞 앱이 bundleID 일 때 각 입력이 무엇을 하는지 돌려준다. 바뀌지 않은 입력은 빠진다.
-- 반환: { keys = { [패드 키 이름] = label }, media = { [미디어 키] = label } }
function doio.describe(bundleID)
    local result = { keys = {}, media = {} }
    for name, keyCode in pairs(padKeyCodes) do
        for _, handler in ipairs(handlers[keyCode] or {}) do
            if handler.app == nil or handler.app == bundleID then
                result.keys[name] = handler.label
                break
            end
        end
    end
    for mediaKey, candidates in pairs(mediaHandlers) do
        for _, handler in ipairs(candidates) do
            if handler.app == bundleID then
                result.media[mediaKey] = handler.label
                break
            end
        end
    end
    return result
end

doio.frontmostApplication = frontmostApplication

doio.tap:start()
doio.mediaTap:start()

return doio
