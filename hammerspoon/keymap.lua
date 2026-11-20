-- 단축키를 설명과 함께 등록한다. 단축키 안내 창(shortcuts.lua)이 여기 등록된 목록을 그대로 보여준다.
-- 키를 바인딩하는 코드와 안내 문구가 한곳에 있어 둘이 어긋나지 않는다.
local keymap = {}

local sections = {}
local sectionIndex = {}

local MOD_ORDER = { { "ctrl", "⌃" }, { "alt", "⌥" }, { "shift", "⇧" }, { "cmd", "⌘" } }

local KEY_LABELS = {
    ["return"] = "⏎", delete = "⌫", forwarddelete = "⌦", escape = "⎋", tab = "⇥", space = "Space",
    left = "←", right = "→", up = "↑", down = "↓",
}

function keymap.modsLabel(mods)
    local set = {}
    for _, mod in ipairs(mods or {}) do
        set[mod] = true
    end
    local label = ""
    for _, pair in ipairs(MOD_ORDER) do
        if set[pair[1]] then
            label = label .. pair[2]
        end
    end
    return label
end

function keymap.keyLabel(key)
    return KEY_LABELS[key] or (#key == 1 and key:upper()) or key
end

local function section(name, prefix)
    if not sectionIndex[name] then
        table.insert(sections, { name = name, prefix = prefix, entries = {} })
        sectionIndex[name] = #sections
    end
    local found = sections[sectionIndex[name]]
    found.prefix = found.prefix or prefix
    return found
end

-- hs.hotkey.bind 와 같고, 안내 창에 보일 설명을 함께 남긴다. repeatFn 이 있으면 누르고 있는 동안 반복한다.
function keymap.bind(sectionName, mods, key, description, fn, repeatFn)
    local hotkey = hs.hotkey.bind(mods, key, fn, nil, repeatFn)
    table.insert(section(sectionName, keymap.modsLabel(mods)).entries, {
        keys = keymap.keyLabel(key),
        description = description,
        repeats = repeatFn ~= nil,
        idx = hotkey.idx,
    })
    return hotkey
end

-- hs.hotkey 가 아닌 입력(마우스 이벤트 탭 등)의 안내만 남긴다.
function keymap.note(sectionName, keys, description)
    table.insert(section(sectionName).entries, { keys = keys, description = description })
end

-- 등록 순서대로 섹션 목록을 돌려준다. 섹션 = { name, prefix(공통 수정키), entries = { keys, description, repeats, idx } }
function keymap.sections()
    return sections
end

return keymap
