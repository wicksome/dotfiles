-- DOIO 설정 페이지를 localhost 에서 띄운다.
-- 페이지(doio-studio/)는 매핑을 /api/mapping 으로 읽고 쓴다. 펌웨어 키맵은 페이지가 WebHID 로 패드와 직접 주고받는다.
-- WebHID 는 Chrome·Edge 에서만 동작하므로 Chrome 으로 연다.
local mapping = require "doio-mapping"
local actions = require "doio-actions"

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

-- macOS 가 기기별로 기억하는 keyboard type. 키 = "PID-VID-0". doio.lua 는 41 인 입력만 패드로 본다.
local KEYBOARD_TYPE_EXPECTED = 41
local KEYBOARD_TYPE_IDS = { usb = "24672-65261-0", bluetooth = "61166-6421-0" }

local function keyboardTypes()
    local output = hs.execute("defaults read /Library/Preferences/com.apple.keyboardtype keyboardtype 2>/dev/null") or ""
    local result = { expected = KEYBOARD_TYPE_EXPECTED }
    local commands = {}
    for which, id in pairs(KEYBOARD_TYPE_IDS) do
        local value = tonumber(output:match('"' .. id:gsub("%-", "%%-") .. '"%s*=%s*(%d+)'))
        result[which] = value
        if value ~= KEYBOARD_TYPE_EXPECTED then
            table.insert(commands, string.format('"%s" -int %d', id, KEYBOARD_TYPE_EXPECTED))
        end
    end
    if #commands > 0 then
        result.fixCommand = "sudo defaults write /Library/Preferences/com.apple.keyboardtype keyboardtype -dict-add "
            .. table.concat(commands, " ")
    end
    return json(200, result)
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
    elseif route == "/api/keyboard-type" and method == "GET" then
        return keyboardTypes()
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
