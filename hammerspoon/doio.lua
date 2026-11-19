-- DOIO KB16B-02 매크로 패드 입력을 가로채 동작이나 다른 키로 바꾼다.
-- 패드는 숫자·방향키 같은 보통 키를 보내므로, 키 이벤트를 보낸 기기로 다른 키보드와 패드를 구분한다.
-- 키 이벤트의 87번 값은 그 키를 보낸 HID 서비스의 IORegistry ID 다(공개 문서에는 없는 값).
-- 이 ID 를 ioreg 로 찾아 제조사·제품 ID 가 패드면 패드 입력으로 본다. ID 는 다시 연결할 때마다 바뀐다.
-- 87번 값이 없거나 찾지 못하면 keyboard type 41 로 판단한다(예전 방식. README 의 등록 명령).
-- 패드 사용법(B/R 버튼, 유선 전환, VIA json, BT 1대 제한):
-- https://blog.naver.com/cotton_mellow_s2/223348486592
local doio = {}

local FALLBACK_KEYBOARD_TYPE = 41
local EVENT_SENDER_FIELD = 87
-- "제조사 ID:제품 ID" → 연결 방식
local PAD_DEVICES = { ["6421:61166"] = "Bluetooth", ["65261:24672"] = "USB" }
-- 이 모듈이 다시 보낸 키 이벤트 표시. 다시 가로채지 않게 한다.
local REMAPPED_EVENT_MARK = 0x444F494F

local types = hs.eventtap.event.types
local properties = hs.eventtap.event.properties

-- 패드 자리 이름. 왼쪽 위부터 행 순서: 1 2 3 4 / 5 6 7 8 / 9 0 up return / bottomLeft left down right
-- 노브는 자리마다 이름이 있다. knobLeft·knobRight 는 오른쪽 작은 노브 회전이다(예전 이름 유지).
-- 이름은 물리 자리를 가리킨다. 그 자리가 어떤 키를 보내는지는 펌웨어 키맵이 정한다.
local PAD_INPUTS = {
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "up", "return",
    "bottomLeft", "left", "down", "right",
    "leftKnobLeft", "leftKnobPress", "leftKnobRight",
    "bigKnobLeft", "bigKnobPress", "bigKnobRight",
    "knobLeft", "rightKnobPress", "knobRight",
}

-- 펌웨어 기본 키맵에서 자리마다 보내는 일반 키(hs.keycodes 이름).
-- 레이어 키(bottomLeft = MO3, rightKnobPress = TO)와 미디어 키(나머지 노브)는 맥에 일반 키 이벤트가 오지 않아 빠진다.
local DEFAULT_PAD_KEYS = {
    ["1"] = "1", ["2"] = "2", ["3"] = "3", ["4"] = "4",
    ["5"] = "5", ["6"] = "6", ["7"] = "7", ["8"] = "8",
    ["9"] = "9", ["0"] = "0", ["up"] = "up", ["return"] = "return",
    ["left"] = "left", ["down"] = "down", ["right"] = "right",
    ["knobLeft"] = "pageup", ["knobRight"] = "pagedown",
}

-- doio-firmware.json: 설정 페이지가 USB 로 펌웨어 키맵을 읽을 때마다 저장한다.
-- inputs[자리] = { key = hs.keycodes 이름 } 이면 그 자리는 그 키를 보낸다. key 가 없으면 일반 키를 보내지 않는다.
-- 파일이 없으면(아직 USB 로 읽은 적 없음) 펌웨어 기본 키맵을 쓴다.
local FIRMWARE_PATH = hs.configdir .. "/doio-firmware.json"

local function loadPadKeys()
    local firmware = hs.fs.attributes(FIRMWARE_PATH) and hs.json.read(FIRMWARE_PATH)
    if not (firmware and firmware.inputs) then
        return DEFAULT_PAD_KEYS
    end
    local keys = {}
    for name, input in pairs(firmware.inputs) do
        keys[name] = input.key
    end
    return keys
end

-- 패드 자리 이름 → 그 자리가 보내는 keycode. 일반 키를 보내지 않는 자리는 빠진다.
local padKeyCodes = {}
for name, keyName in pairs(loadPadKeys()) do
    local keyCode = hs.keycodes.map[keyName]
    if keyCode then
        padKeyCodes[name] = keyCode
    end
end

-- keycode → 등록 순서대로의 handler 목록. 조건이 맞는 첫 handler 가 처리한다.
-- handler = { app = bundleID | nil, shortcut = string, description = string,
--             down = function(), up = function() | nil, repeats = boolean }
local handlers = {}

local MOD_SYMBOLS = { { "ctrl", "⌃" }, { "alt", "⌥" }, { "shift", "⇧" }, { "cmd", "⌘" } }
local KEY_SYMBOLS = {
    up = "↑", down = "↓", left = "←", right = "→",
    ["return"] = "⏎", delete = "⌫", tab = "⇥", space = "␣", escape = "⎋",
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

-- IORegistry ID → { id, name, vendorID, productID, transport, isPad }
local senders = {}

local function scanSenders()
    local output = hs.execute("/usr/sbin/ioreg -r -c IOHIDEventService -d1 -w0 -l") or ""
    local current
    for line in output:gmatch("[^\n]+") do
        local id = line:match("<class [^,]+, id (0x%x+)")
        if id then
            current = { id = id }
            senders[tonumber(id)] = current
        elseif current then
            local key, value = line:match('"(%w+)" = (.+)$')
            if key == "VendorID" or key == "ProductID" then
                current[key == "VendorID" and "vendorID" or "productID"] = tonumber(value)
            elseif key == "Product" or key == "Transport" then
                current[key == "Product" and "name" or "transport"] = value:match('^"(.*)"$')
            end
        end
    end
    for _, sender in pairs(senders) do
        sender.isPad = PAD_DEVICES[tostring(sender.vendorID) .. ":" .. tostring(sender.productID)] ~= nil
    end
end

-- 처음 보는 ID 일 때만 ioreg 를 다시 읽는다(약 60ms). 찾지 못한 ID 도 기억해 다시 읽지 않는다.
local function senderOf(senderID)
    if senderID == 0 then
        return nil
    end
    if not senders[senderID] then
        scanSenders()
        senders[senderID] = senders[senderID] or { id = string.format("0x%x", senderID) }
    end
    return senders[senderID]
end

-- 설정 페이지에 보여줄, 키를 보낸 기기 기록. IORegistry ID → 기기 정보 + 마지막 입력
doio.seenSenders = {}

local function isFromPad(event)
    if event:getProperty(properties.eventSourceUserData) == REMAPPED_EVENT_MARK then
        return false
    end
    local senderID = event:getProperty(EVENT_SENDER_FIELD)
    local keyboardType = event:getProperty(properties.keyboardEventKeyboardType)
    local sender = senderOf(senderID)
    local fromPad, method
    if sender and sender.vendorID then
        fromPad, method = sender.isPad, "기기"
    else
        fromPad, method = keyboardType == FALLBACK_KEYBOARD_TYPE, "keyboard type"
    end
    if event:getType() == types.keyDown then
        local seen = doio.seenSenders[senderID] or {}
        doio.seenSenders[senderID] = seen
        seen.id = sender and sender.id or string.format("0x%x", senderID)
        seen.name = sender and sender.name
        seen.transport = sender and sender.transport
        seen.vendorID = sender and sender.vendorID
        seen.productID = sender and sender.productID
        seen.keyboardType = keyboardType
        seen.isPad = fromPad
        seen.method = method
        seen.lastSeen = os.time()
    end
    return fromPad
end

scanSenders()

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
    if not keyCode then
        -- 펌웨어에서 이 자리를 레이어 키·미디어 키로 바꾸면 맥에 일반 키가 오지 않는다. 규칙은 남겨 두고 건너뛴다.
        print("doio: " .. tostring(name) .. " 자리는 지금 펌웨어에서 일반 키를 보내지 않아 규칙을 건너뛴다")
        return
    end
    -- 앱 조건이 있는 handler 를 앞에 두어 전체 적용 handler 보다 먼저 고른다.
    handlers[keyCode] = handlers[keyCode] or {}
    if handler.app then
        table.insert(handlers[keyCode], 1, handler)
    else
        table.insert(handlers[keyCode], handler)
    end
end

-- 패드 키를 누르면 action 을 한 번 실행한다. options.app 이 있으면 그 앱이 앞에 있을 때만 적용한다.
-- options.up 이 있으면 키를 뗄 때 실행한다.
-- 배치 보기 화면에는 options.shortcut(윗줄)과 options.description(아랫줄)을 표시한다.
function doio.bind(name, action, options)
    options = options or {}
    register(name, {
        app = options.app,
        shortcut = options.shortcut or "동작",
        description = options.description or "",
        down = action,
        up = options.up,
    })
end

-- options.app 이 앞에 있을 때 이 키가 아무 동작도 하지 않게 막는다. 배치 보기 화면에는 ✕ 로 표시한다.
function doio.block(name, options)
    register(name, { app = options.app, blocked = true, down = function() end })
end

-- 패드 키를 다른 키(조합)로 바꿔 보낸다. 누르고 있는 동안의 반복도 그대로 전달한다.
-- options.mods = { "cmd", "shift", ... }, options.app = bundleID
function doio.remap(name, targetKeyName, options)
    options = options or {}
    local mods = options.mods or {}
    assert(hs.keycodes.map[targetKeyName], "unknown target key: " .. tostring(targetKeyName))
    register(name, {
        app = options.app,
        shortcut = options.shortcut or shortcutLabel(mods, targetKeyName),
        description = options.description or "",
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
        if handler.app == nil or handler.app == bundleID then
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
    assert(options and (options.app or options.blocked), "bindMedia needs options.app")
    mediaHandlers[mediaKey] = mediaHandlers[mediaKey] or {}
    local handler = {
        app = options.app,
        shortcut = options.shortcut or "동작",
        description = options.description or "",
        down = action,
        blocked = options.blocked,
    }
    -- 앱 조건이 있는 handler 를 앞에 두어 모든 앱 handler 보다 먼저 고른다.
    if handler.app then
        table.insert(mediaHandlers[mediaKey], 1, handler)
    else
        table.insert(mediaHandlers[mediaKey], handler)
    end
end

-- 미디어 키가 아무 동작도 하지 않게 막는다. 배치 보기 화면에는 ✕ 로 표시한다.
-- options.app 이 없으면 모든 앱에서 막는다. 노트북 미디어 키도 함께 막힌다.
function doio.blockMedia(mediaKey, options)
    doio.bindMedia(mediaKey, function() end, { app = options and options.app, blocked = true })
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
        shortcut = options.shortcut or shortcutLabel(mods, targetKeyName),
        description = options.description,
    })
end

-- 앞 앱이 bundleID 일 때 각 입력이 무엇을 하는지 돌려준다. 바뀌지 않은 입력은 빠진다.
-- 반환: { keys = { [패드 키 이름] = { shortcut, description } }, media = { [미디어 키] = { shortcut, description } } }
function doio.describe(bundleID)
    local result = { keys = {}, media = {} }
    for name, keyCode in pairs(padKeyCodes) do
        for _, handler in ipairs(handlers[keyCode] or {}) do
            if handler.app == nil or handler.app == bundleID then
                result.keys[name] = { shortcut = handler.shortcut, description = handler.description,
                                      appSpecific = handler.app ~= nil, blocked = handler.blocked }
                break
            end
        end
    end
    for mediaKey, candidates in pairs(mediaHandlers) do
        for _, handler in ipairs(candidates) do
            if handler.app == nil or handler.app == bundleID then
                result.media[mediaKey] = { shortcut = handler.shortcut, description = handler.description,
                                           appSpecific = handler.app ~= nil, blocked = handler.blocked }
                break
            end
        end
    end
    return result
end

doio.frontmostApplication = frontmostApplication

-- 패드 자리 이름인지 돌려준다. doio-mapping.lua 가 규칙을 검사할 때 쓴다.
-- 지금 펌웨어에서 일반 키를 보내는지와는 상관없다. 펌웨어를 바꿔도 규칙 파일이 오류가 되지 않게 한다.
function doio.isPadKey(name)
    for _, input in ipairs(PAD_INPUTS) do
        if input == name then
            return true
        end
    end
    return false
end

doio.tap:start()
doio.mediaTap:start()

return doio
