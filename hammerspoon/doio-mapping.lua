-- doio-mapping.json 의 규칙을 읽어 DOIO 패드에 연결한다.
-- 규칙 하나 = 입력(key 또는 media) + 적용 앱(app, 없으면 모든 앱) + 할 일(block / send / action 중 하나).
-- 같은 입력에 앱 규칙과 모든 앱 규칙이 함께 있으면 앱 규칙이 우선한다(doio.lua 의 register 순서).
local doio = require "doio"
local actions = require "doio-actions"

local mapping = {}

mapping.path = hs.configdir .. "/doio-mapping.json"

local function describeRule(index, rule)
    return string.format("doio-mapping.json rules[%d] (%s)", index, rule.key or rule.media or "?")
end

local function makeAction(index, rule)
    local action = actions[rule.action]
    assert(action, describeRule(index, rule) .. ": unknown action " .. tostring(rule.action))
    local params = rule.params or {}
    for name, kind in pairs(action.params) do
        assert(type(params[name]) == kind,
            describeRule(index, rule) .. ": params." .. name .. " must be " .. kind)
    end
    return action.make(params)
end

local function applyKeyRule(index, rule)
    local options = { app = rule.app, shortcut = rule.shortcut, description = rule.description }
    if rule.block then
        doio.block(rule.key, options)
    elseif rule.send then
        options.mods = rule.send.mods
        doio.remap(rule.key, rule.send.key, options)
    else
        local down, up = makeAction(index, rule)
        options.up = up
        doio.bind(rule.key, down, options)
    end
end

local function applyMediaRule(index, rule)
    if rule.block then
        doio.blockMedia(rule.media, { app = rule.app })
    elseif rule.send then
        doio.remapMedia(rule.media, rule.send.key, {
            app = rule.app, mods = rule.send.mods, shortcut = rule.shortcut, description = rule.description,
        })
    else
        local down = makeAction(index, rule)
        doio.bindMedia(rule.media, down, { app = rule.app, shortcut = rule.shortcut, description = rule.description })
    end
end

local function apply(index, rule)
    local doCount = (rule.block and 1 or 0) + (rule.send and 1 or 0) + (rule.action and 1 or 0)
    assert(doCount == 1, describeRule(index, rule) .. ": needs exactly one of block, send, action")
    if rule.key then
        applyKeyRule(index, rule)
    elseif rule.media then
        applyMediaRule(index, rule)
    else
        error(describeRule(index, rule) .. ": needs key or media")
    end
end

function mapping.load()
    local data = hs.json.read(mapping.path)
    assert(data and data.rules, "cannot read " .. mapping.path)
    for index, rule in ipairs(data.rules) do
        apply(index, rule)
    end
end

mapping.load()

return mapping
