-- 지금 켜진 Hammerspoon 설정의 단축키를 창 하나에 보여준다.
-- 키보드·마우스는 keymap.lua 에 등록된 목록을, DOIO 패드는 doio-mapping.json 을 읽어 그린다.
-- 설명 없이 hs.hotkey 로 직접 묶은 키는 「설명 없는 단축키」에 나온다.
local keymap = require "keymap"
local mapping = require "doio-mapping"
local actions = require "doio-actions"

local shortcuts = {}

local function escape(text)
    return (tostring(text or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function row(keys, description, note)
    return string.format("<tr><td class=\"keys\"><kbd>%s</kbd></td><td>%s%s</td></tr>",
        escape(keys), escape(description), note and (" <span class=\"note\">" .. escape(note) .. "</span>") or "")
end

local function table_(rows)
    return "<table>" .. table.concat(rows) .. "</table>"
end

-- 설명이 같은 연속 키(그리드 1~6 등)는 「처음 ~ 끝」 한 줄로 묶는다
local function mergedEntries(entries)
    local merged = {}
    for _, entry in ipairs(entries) do
        local last = merged[#merged]
        if last and last.description == entry.description and last.repeats == entry.repeats then
            last.lastKeys = entry.keys
        else
            table.insert(merged, { keys = entry.keys, description = entry.description, repeats = entry.repeats })
        end
    end
    return merged
end

local function keymapSections()
    local html = {}
    for _, section in ipairs(keymap.sections()) do
        local rows = {}
        for _, entry in ipairs(mergedEntries(section.entries)) do
            local keys = entry.lastKeys and (entry.keys .. " ~ " .. entry.lastKeys) or entry.keys
            table.insert(rows, row(keys, entry.description, entry.repeats and "누르고 있으면 반복" or nil))
        end
        local prefix = section.prefix and section.prefix ~= ""
            and string.format(" <span class=\"prefix\"><kbd>%s</kbd> + 키</span>", escape(section.prefix)) or ""
        table.insert(html, { size = #rows + 2, html = string.format("<section><h2>%s%s</h2>%s</section>",
            escape(section.name), prefix, table_(rows)) })
    end
    return html
end

-- 섹션을 줄 수가 적은 단에 차례로 넣어 두 단 높이를 맞춘다. 섹션은 단을 넘어가지 않는다.
local function twoColumns(blocks)
    local columns = { { size = 0, html = {} }, { size = 0, html = {} } }
    for _, block in ipairs(blocks) do
        local target = columns[1].size <= columns[2].size and columns[1] or columns[2]
        target.size = target.size + block.size
        table.insert(target.html, block.html)
    end
    return string.format('<div class="cols"><div>%s</div><div>%s</div></div>',
        table.concat(columns[1].html), table.concat(columns[2].html))
end

local function unregisteredHotkeys()
    local known = {}
    for _, section in ipairs(keymap.sections()) do
        for _, entry in ipairs(section.entries) do
            if entry.idx then
                known[entry.idx] = true
            end
        end
    end
    local rows = {}
    for _, hotkey in ipairs(hs.hotkey.getHotkeys()) do
        if not known[hotkey.idx] then
            table.insert(rows, row(hotkey.idx, hotkey.msg ~= hotkey.idx and hotkey.msg or "설명 없음"))
        end
    end
    if #rows == 0 then
        return nil
    end
    return { size = #rows + 3, html = "<section><h2>설명 없는 단축키</h2><p class=\"sub\">keymap.bind 를 거치지 않고 묶인 키다.</p>"
        .. table_(rows) .. "</section>" }
end

local function doioDoes(rule)
    if rule.block then
        return "막음 (아무 동작 없음)"
    end
    local label = rule.description or rule.shortcut
    if rule.send then
        local sent = keymap.modsLabel(rule.send.mods) .. keymap.keyLabel(rule.send.key)
        return label and (label .. " (" .. sent .. ")") or (sent .. " 보내기")
    end
    local action = actions[rule.action]
    return label or (action and action.label) or rule.action
end

local function appName(bundleID)
    if not bundleID then
        return "모든 앱"
    end
    return hs.application.nameForBundleID(bundleID) or bundleID
end

local function doioSection()
    local ok, data = pcall(mapping.read)
    if not ok or not data then
        return "<section><h2>DOIO 패드</h2><p class=\"sub\">doio-mapping.json 을 읽지 못했다.</p></section>"
    end
    local groups, order = {}, {}
    for _, rule in ipairs(data.rules or {}) do
        local app = rule.app or ""
        if not groups[app] then
            groups[app] = {}
            table.insert(order, app)
        end
        local input = rule.key and ("키 " .. rule.key) or ("미디어 " .. rule.media)
        table.insert(groups[app], row(input, doioDoes(rule)))
    end
    table.sort(order, function(a, b) return a == "" or (b ~= "" and appName(a) < appName(b)) end)
    local html = {}
    for _, app in ipairs(order) do
        table.insert(html, string.format("<h3>%s</h3>%s", escape(appName(app ~= "" and app or nil)), table_(groups[app])))
    end
    return "<section><h2>DOIO 패드</h2><p class=\"sub\">앱 규칙이 모든 앱 규칙보다 먼저 적용된다. "
        .. "자리 그림은 DOIO Studio 에서 본다.</p>" .. table.concat(html) .. "</section>"
end

local function keyboardColumns()
    local blocks = keymapSections()
    local unregistered = unregisteredHotkeys()
    if unregistered then
        table.insert(blocks, unregistered)
    end
    return twoColumns(blocks)
end

local STYLE = [[
:root { color-scheme: light dark; --bg:#fafafa; --fg:#1d1d1f; --sub:#6e6e73; --line:#e3e3e8; --kbd:#ececf1; }
@media (prefers-color-scheme: dark) { :root { --bg:#1e1e22; --fg:#f2f2f5; --sub:#a1a1a8; --line:#34343a; --kbd:#2e2e35; } }
body { margin:0; padding:40px 24px 20px; background:var(--bg); color:var(--fg); font:13px -apple-system, sans-serif; }
h1 { font-size:18px; margin:0 0 4px; }
.sub { color:var(--sub); margin:2px 0 8px; }
.cols { display:grid; grid-template-columns: 1fr 1fr; column-gap: 28px; align-items:start; }
section { break-inside: avoid; margin: 16px 0 0; }
h2 { font-size:14px; margin:0 0 6px; padding-bottom:4px; border-bottom:1px solid var(--line); }
h3 { font-size:12px; margin:12px 0 4px; color:var(--sub); }
.prefix { font-weight:normal; color:var(--sub); font-size:12px; margin-left:6px; }
table { border-collapse:collapse; width:100%; }
td { padding:3px 6px; border-bottom:1px solid var(--line); vertical-align:top; }
td.keys { width:1%; white-space:nowrap; }
kbd { background:var(--kbd); border-radius:4px; padding:1px 6px; font:12px Menlo, monospace; }
.note { color:var(--sub); font-size:11px; }
]]

local function render()
    return string.format([[<!doctype html><html><head><meta charset="utf-8"><style>%s</style></head><body>
<h1>Hammerspoon 단축키</h1>
<p class="sub">지금 불러온 설정에서 읽었다 (%s). Esc 로 닫는다.</p>
%s%s
<script>
document.addEventListener("keydown", e => {
  if (e.key === "Escape") window.webkit.messageHandlers.shortcuts.postMessage("close");
});
</script>
</body></html>]], STYLE, os.date("%Y-%m-%d %H:%M"), keyboardColumns(), doioSection())
end

local view

function shortcuts.hide()
    if view then
        view:delete()
        view = nil
    end
end

function shortcuts.show()
    shortcuts.hide()
    local screen = hs.screen.mainScreen():frame()
    local width, height = math.min(960, screen.w - 80), math.min(820, screen.h - 80)
    local content = hs.webview.usercontent.new("shortcuts")
    content:setCallback(function(message)
        if message.body == "close" then
            shortcuts.hide()
        end
    end)
    view = hs.webview.new({
        x = screen.x + (screen.w - width) / 2,
        y = screen.y + (screen.h - height) / 2,
        w = width,
        h = height,
    }, {}, content)
    -- 내용을 제목줄 아래까지 그려 제목줄이 페이지 배경색을 따르게 한다. 창 외형은 시스템 다크/라이트를 따른다.
    view:windowStyle({ "titled", "closable", "resizable", "fullSizeContentView" })
    view:darkMode(hs.host.interfaceStyle() == "Dark")
    view:windowTitle("Hammerspoon 단축키")
    view:allowTextEntry(true)
    view:deleteOnClose(true)
    view:windowCallback(function(action)
        if action == "closing" then
            view = nil
        end
    end)
    view:html(render())
    view:show()
    view:bringToFront(true)
    view:hswindow():focus()
end

function shortcuts.toggle()
    if view then
        shortcuts.hide()
    else
        shortcuts.show()
    end
end

return shortcuts
