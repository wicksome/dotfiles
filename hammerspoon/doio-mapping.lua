-- doio-mapping.json 의 규칙을 읽어 DOIO 패드에 연결한다.
-- 매핑은 개인 설정이라 이 공개 레포에 두지 않는다. 비공개 dotfiles 가 ~/.config/doio/doio-mapping.json 으로 링크한다.
-- 규칙 하나 = 입력(key 또는 media) + 적용 앱(app, 없으면 모든 앱) + 할 일(block / send / action 중 하나).
-- 같은 입력에 앱 규칙과 모든 앱 규칙이 함께 있으면 앱 규칙이 우선한다(doio.lua 의 register 순서).
local doio = require "doio"
local actions = require "doio-actions"

local mapping = {}

mapping.path = os.getenv("HOME") .. "/.config/doio/doio-mapping.json"

mapping.mediaKeys = { "PLAY", "NEXT", "PREVIOUS", "MUTE", "SOUND_UP", "SOUND_DOWN" }
mapping.mods = { "cmd", "alt", "shift", "ctrl" }

local function contains(list, value)
    for _, item in ipairs(list) do
        if item == value then
            return true
        end
    end
    return false
end

local function ruleProblems(rule)
    local problems = {}
    local function check(ok, message)
        if not ok then
            table.insert(problems, message)
        end
    end
    if rule.key ~= nil then
        check(rule.media == nil, "key 와 media 를 함께 쓸 수 없다")
        check(doio.isPadKey(rule.key), "모르는 패드 키: " .. tostring(rule.key))
    else
        check(contains(mapping.mediaKeys, rule.media), "모르는 미디어 키: " .. tostring(rule.media))
    end
    check(rule.app == nil or type(rule.app) == "string", "app 은 번들 ID 문자열이다")
    local doCount = (rule.block and 1 or 0) + (rule.send and 1 or 0) + (rule.action and 1 or 0)
    check(doCount == 1, "block, send, action 중 정확히 하나만 쓴다")
    if rule.media ~= nil and rule.app == nil then
        check(rule.block == true, "미디어 키는 노트북 키와 구분되지 않아 막기 말고는 app 이 필요하다")
    end
    if rule.send then
        check(hs.keycodes.map[rule.send.key] ~= nil, "모르는 키: " .. tostring(rule.send.key))
        for _, mod in ipairs(rule.send.mods or {}) do
            check(contains(mapping.mods, mod), "모르는 수정키: " .. tostring(mod))
        end
    end
    if rule.action then
        local action = actions[rule.action]
        check(action ~= nil, "모르는 동작: " .. tostring(rule.action))
        if action then
            local params = rule.params or {}
            for name, kind in pairs(action.params) do
                check(type(params[name]) == kind, "params." .. name .. " 은 " .. kind .. " 이다")
            end
        end
    end
    return problems
end

-- 규칙 목록의 문제를 "rules[번호] (입력): 내용" 문자열 목록으로 돌려준다. 문제가 없으면 빈 목록이다.
-- 설정 페이지가 저장하기 전에 같은 함수로 검사한다.
function mapping.validate(data)
    if type(data) ~= "table" or type(data.rules) ~= "table" then
        return { "rules 목록이 없다" }
    end
    local problems = {}
    local seen = {}
    for index, rule in ipairs(data.rules) do
        local label = string.format("rules[%d] (%s)", index, tostring(rule.key or rule.media))
        for _, problem in ipairs(ruleProblems(rule)) do
            table.insert(problems, label .. ": " .. problem)
        end
        local identity = tostring(rule.key or rule.media) .. "@" .. tostring(rule.app or "*")
        if seen[identity] then
            table.insert(problems, label .. ": 같은 입력·앱 규칙이 rules[" .. seen[identity] .. "] 에 이미 있다")
        end
        seen[identity] = index
    end
    return problems
end

local function apply(rule)
    local options = { app = rule.app, shortcut = rule.shortcut, description = rule.description }
    local down, up
    if rule.action then
        down, up = actions[rule.action].make(rule.params or {})
    end
    if rule.key then
        if rule.block then
            doio.block(rule.key, options)
        elseif rule.send then
            options.mods = rule.send.mods
            doio.remap(rule.key, rule.send.key, options)
        else
            options.up = up
            options.returnsFrom = rule.action == "openApp" and rule.params.bundleID or nil
            doio.bind(rule.key, down, options)
        end
    elseif rule.block then
        doio.blockMedia(rule.media, { app = rule.app })
    elseif rule.send then
        options.mods = rule.send.mods
        doio.remapMedia(rule.media, rule.send.key, options)
    else
        doio.bindMedia(rule.media, down, options)
    end
end

-- 파일이 없으면(비공개 설정이 없는 맥) 규칙 없이 시작한다. DOIO Studio 에서 저장하면 만들어진다.
function mapping.read()
    if not hs.fs.attributes(mapping.path) then
        return { rules = {} }
    end
    return hs.json.read(mapping.path)
end

function mapping.load()
    local data = mapping.read()
    local problems = mapping.validate(data)
    if #problems > 0 then
        hs.alert.show("doio-mapping.json 오류 " .. #problems .. "건 — 콘솔 확인", 5)
        error("doio-mapping.json\n" .. table.concat(problems, "\n"))
    end
    for _, rule in ipairs(data.rules) do
        apply(rule)
    end
end

mapping.load()

return mapping
