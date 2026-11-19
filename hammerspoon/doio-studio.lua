-- DOIO 설정 페이지를 localhost 에서 띄운다.
-- 페이지(doio-studio/)는 매핑을 /api/mapping 으로 읽고 쓴다. 펌웨어 키맵은 페이지가 WebHID 로 패드와 직접 주고받는다.
-- WebHID 는 Chrome·Edge 에서만 동작하므로 Chrome 으로 연다.
local mapping = require "doio-mapping"
local actions = require "doio-actions"
local doio = require "doio"

local studio = {}

studio.port = 17816
studio.url = "http://localhost:" .. studio.port .. "/"

local STATIC_DIR = hs.configdir .. "/doio-studio"
local FIRMWARE_PATH = hs.configdir .. "/doio-firmware.json"
local STATIC_TYPES = { html = "text/html; charset=utf-8", js = "text/javascript; charset=utf-8", css = "text/css; charset=utf-8" }
-- 다른 웹 페이지가 localhost 로 매핑을 덮어쓰지 못하게, 쓰기 요청에는 이 헤더를 요구한다.
-- 사용자 정의 헤더가 붙은 교차 출처 요청은 브라우저가 사전 요청(preflight)을 보내고, 이 서버는 허용하지 않는다.
local WRITE_HEADER = "X-DOIO-Studio"

local function respond(code, body, contentType)
    return body, code, { ["Content-Type"] = contentType or "application/json; charset=utf-8", ["Cache-Control"] = "no-store" }
end

local function json(code, value)
    return respond(code, hs.json.encode(value))
end

local function readFile(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local text = file:read("a")
    file:close()
    return text
end

local function serveStatic(path)
    local name = path == "/" and "index.html" or path:match("^/([%w%-_]+%.%w+)$")
    if not name then
        return respond(404, "not found", "text/plain")
    end
    local text = readFile(STATIC_DIR .. "/" .. name)
    if not text then
        return respond(404, "not found", "text/plain")
    end
    return respond(200, text, STATIC_TYPES[name:match("%.(%w+)$")] or "text/plain")
end

local function appNames(data)
    local names = {}
    for _, rule in ipairs(data.rules or {}) do
        if rule.app and not names[rule.app] then
            names[rule.app] = hs.application.nameForBundleID(rule.app) or rule.app
        end
    end
    return names
end

local function actionCatalog()
    local catalog = {}
    for name, action in pairs(actions) do
        catalog[name] = { label = action.label, params = action.params }
    end
    return catalog
end

local function getMapping()
    local data = mapping.read() or { rules = {} }
    local firmwareText = readFile(FIRMWARE_PATH)
    return json(200, {
        mapping = data,
        firmware = firmwareText and hs.json.decode(firmwareText),
        actions = actionCatalog(),
        mediaKeys = mapping.mediaKeys,
        mods = mapping.mods,
        appNames = appNames(data),
    })
end

-- 본문 텍스트를 그대로 저장한다. 페이지가 규칙을 한 줄에 하나씩 써서 보내 git diff 가 읽기 쉽다.
local function putMapping(headers, body)
    if not headers[WRITE_HEADER] then
        return json(403, { problems = { WRITE_HEADER .. " 헤더가 없다" } })
    end
    local ok, data = pcall(hs.json.decode, body or "")
    if not ok or not data then
        return json(400, { problems = { "JSON 을 읽을 수 없다" } })
    end
    local problems = mapping.validate(data)
    if #problems > 0 then
        return json(400, { problems = problems })
    end
    local file = assert(io.open(mapping.path, "w"))
    file:write(body)
    file:close()
    -- 응답을 보낸 뒤 리로드한다. 리로드하면 이 서버도 다시 뜬다.
    hs.timer.doAfter(0.3, hs.reload)
    return json(200, { saved = #data.rules })
end

-- 페이지가 USB 로 읽은 펌웨어 키맵 요약(자리 → 보내는 키)을 저장한다. doio.lua 가 이 파일로 자리를 알아본다.
-- 내용이 같으면 쓰지도 리로드하지도 않는다.
local function putFirmware(headers, body)
    if not headers[WRITE_HEADER] then
        return json(403, { problems = { WRITE_HEADER .. " 헤더가 없다" } })
    end
    local ok, data = pcall(hs.json.decode, body or "")
    if not ok or type(data) ~= "table" or type(data.inputs) ~= "table" then
        return json(400, { problems = { "inputs 가 없다" } })
    end
    if readFile(FIRMWARE_PATH) == body then
        return json(200, { changed = false })
    end
    local file = assert(io.open(FIRMWARE_PATH, "w"))
    file:write(body)
    file:close()
    hs.timer.doAfter(0.3, hs.reload)
    return json(200, { changed = true })
end

local function lookupApp(query)
    local bundleID = query:match("bundleID=([%w%.%-_]+)")
    if not bundleID then
        return json(400, { problems = { "bundleID 가 없다" } })
    end
    return json(200, { bundleID = bundleID, name = hs.application.nameForBundleID(bundleID) })
end

local function runningApps()
    local apps = {}
    for _, app in ipairs(hs.application.runningApplications()) do
        local bundleID = app:bundleID()
        if bundleID and app:kind() == 1 then
            table.insert(apps, { bundleID = bundleID, name = app:name() })
        end
    end
    table.sort(apps, function(a, b) return a.name:lower() < b.name:lower() end)
    return json(200, apps)
end

-- 패드가 USB 로 꽂혀 있는지. Bluetooth 연결에는 VIA 통신 인터페이스가 없어 펌웨어 키맵을 읽고 쓸 수 없다.
local PAD_VENDOR_ID = 0xFEED
local PAD_PRODUCT_ID = 0x6060

local function padStatus()
    local usb = false
    for _, device in ipairs(hs.usb.attachedDevices() or {}) do
        if device.vendorID == PAD_VENDOR_ID and device.productID == PAD_PRODUCT_ID then
            usb = true
        end
    end
    return json(200, { usb = usb })
end

-- 최근 키를 보낸 기기. doio.lua 는 키를 보낸 기기(이벤트 87번 값)로 패드를 알아보고,
-- 그 값을 못 얻을 때만 keyboard type 41 로 판단한다. 기기마다 keyboard type 도 함께 보여준다.
local function inputDevices()
    -- 지금 연결된 HID 서비스. 다시 연결하면 ID 가 바뀌므로, 목록에 없는 기록은 끊긴 예전 기록이다.
    -- 키를 누르기 전에도 패드 연결 방식을 보이려고 패드 서비스의 연결 방식도 모은다.
    local connected, padTransports = {}, {}
    local currentID, vendorID
    for line in (hs.execute("/usr/sbin/ioreg -r -c IOHIDEventService -d1 -w0 -l") or ""):gmatch("[^\n]+") do
        local id = line:match("<class [^,]+, id (0x%x+)")
        if id then
            currentID, vendorID = id, nil
            connected[id] = true
        end
        vendorID = tonumber(line:match('"VendorID" = (%d+)')) or vendorID
        local transport = line:match('"Transport" = "(.-)"')
        if transport and (vendorID == 6421 or vendorID == 65261) then
            padTransports[transport:find("Bluetooth") and "Bluetooth" or transport] = true
        end
    end
    local seen = {}
    for _, sender in pairs(doio.seenSenders) do
        sender.connected = connected[sender.id] == true
        table.insert(seen, sender)
    end
    table.sort(seen, function(a, b) return a.lastSeen > b.lastSeen end)
    local pads = {}
    for transport in pairs(padTransports) do
        table.insert(pads, transport)
    end
    table.sort(pads)
    return json(200, { seen = seen, connectedPads = pads })
end

-- 패드 배터리. Bluetooth 로 연결됐을 때만 macOS 가 알려준다(system_profiler, 약 0.15초).
-- 얼마나 썼는지 보려고 값이 바뀔 때마다 시각과 함께 기록한다. 기록은 이 맥에만 둔다(저장소 밖).
local BATTERY_HISTORY_PATH = os.getenv("HOME") .. "/Library/Caches/doio-battery.json"
local BATTERY_HISTORY_LIMIT = 500

local function readPadBattery()
    local output = hs.execute("/usr/sbin/system_profiler SPBluetoothDataType -json 2>/dev/null") or ""
    local ok, data = pcall(hs.json.decode, output)
    if not ok or type(data) ~= "table" then
        return { connected = false }
    end
    for _, controller in ipairs(data.SPBluetoothDataType or {}) do
        for _, device in ipairs(controller.device_connected or {}) do
            for name, info in pairs(device) do
                if name:find("DOIO") then
                    return { connected = true, level = tonumber(tostring(info.device_batteryLevelMain or ""):match("(%d+)")) }
                end
            end
        end
    end
    return { connected = false }
end

local function batteryHistory()
    return (hs.fs.attributes(BATTERY_HISTORY_PATH) and hs.json.read(BATTERY_HISTORY_PATH)) or {}
end

local function recordBattery()
    local battery = readPadBattery()
    if battery.level then
        local history = batteryHistory()
        local last = history[#history]
        if not last or last.level ~= battery.level then
            table.insert(history, { time = os.time(), level = battery.level })
            while #history > BATTERY_HISTORY_LIMIT do
                table.remove(history, 1)
            end
            hs.json.write(history, BATTERY_HISTORY_PATH, false, true)
        end
    end
    return battery
end

studio.batteryTimer = hs.timer.doEvery(600, recordBattery)

local function padBattery()
    local battery = recordBattery()
    battery.history = batteryHistory()
    battery.now = os.time()
    return json(200, battery)
end

studio.server = hs.httpserver.new(false, false)
studio.server:setInterface("localhost")
studio.server:setPort(studio.port)
local function handleRequest(method, path, headers, body)
    local route, query = path:match("^([^?]*)%??(.*)$")
    if route == "/api/mapping" and method == "GET" then
        return getMapping()
    elseif route == "/api/mapping" and method == "PUT" then
        return putMapping(headers, body)
    elseif route == "/api/firmware" and method == "PUT" then
        return putFirmware(headers, body)
    elseif route == "/api/battery" and method == "GET" then
        return padBattery()
    elseif route == "/api/input-devices" and method == "GET" then
        return inputDevices()
    elseif route == "/api/pad" and method == "GET" then
        return padStatus()
    elseif route == "/api/apps" and method == "GET" then
        return runningApps()
    elseif route == "/api/app" and method == "GET" then
        return lookupApp(query)
    elseif method == "GET" then
        return serveStatic(route)
    end
    return respond(405, "method not allowed", "text/plain")
end

-- 처리 중 오류가 나면 페이지가 원인을 볼 수 있게 500 과 메시지를 돌려준다(콘솔에도 남긴다).
studio.server:setCallback(function(method, path, headers, body)
    local ok, responseBody, code, responseHeaders = pcall(handleRequest, method, path, headers, body)
    if ok then
        return responseBody, code, responseHeaders
    end
    print("doio-studio: " .. method .. " " .. path .. " 오류: " .. tostring(responseBody))
    return json(500, { problems = { tostring(responseBody) } })
end)
studio.server:start()

function studio.open()
    hs.urlevent.openURLWithBundle(studio.url, "com.google.Chrome")
end

return studio
