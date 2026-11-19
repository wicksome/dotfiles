-- DOIO 패드의 현재 배치를 화면에 그려 보여준다. 앞 앱 기준으로 바뀐 입력을 강조한다.
local doio = require "doio"

local overlay = {}

local SHOW_SECONDS = 10

-- 왼쪽 위부터 행 순서. nil 은 펌웨어가 처리해 바꿀 수 없는 레이어 키다.
local GRID = {
    { "1", "2", "3", "4" },
    { "5", "6", "7", "8" },
    { "9", "0", "up", "return" },
    { nil, "left", "down", "right" },
}

local DEFAULT_KEY_LABELS = {
    ["1"] = "1", ["2"] = "2", ["3"] = "3", ["4"] = "4",
    ["5"] = "5", ["6"] = "6", ["7"] = "7", ["8"] = "8",
    ["9"] = "9", ["0"] = "0", up = "↑", ["return"] = "⏎",
    left = "←", down = "↓", right = "→",
    knobLeft = "PgUp", knobRight = "PgDn",
}

local DEFAULT_MEDIA_LABELS = {
    PREVIOUS = "⏮", NEXT = "⏭", PLAY = "⏯",
    SOUND_DOWN = "🔉", SOUND_UP = "🔊", MUTE = "🔇",
}

local function escape(text)
    return (tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- entry = { shortcut, description, appSpecific }. position 은 왼쪽 위 모서리에 작게 적는 위치 번호다.
-- 모든 앱 공통 키는 보내는 키가 윗줄이다. 앱 전용 키는 하는 일(description)이 윗줄이고 보내는 키가 아랫줄이다.
local function cell(entry, changed, fixed, position)
    if entry.blocked then
        return string.format('<div class="cell blocked">%s<b>✕</b></div>',
            position and ('<i class="pos">' .. position .. "</i>") or "")
    end
    local class = fixed and "cell fixed" or (changed and "cell changed" or "cell")
    local main, sub = entry.shortcut, entry.description or ""
    if entry.appSpecific and sub ~= "" then
        main, sub = sub, main
        class = class .. " app"
    end
    return string.format('<div class="%s">%s<b>%s</b>%s</div>', class,
        position and ('<i class="pos">' .. position .. "</i>") or "",
        escape(main),
        sub ~= "" and ("<small>" .. escape(sub) .. "</small>") or "")
end

local function keyCell(description, name, position)
    if name == nil then
        return cell({ shortcut = "MO", description = "레이어" }, false, true, position)
    end
    local entry = description.keys[name]
    return cell(entry or { shortcut = DEFAULT_KEY_LABELS[name] }, entry ~= nil, false, position)
end

local function knobAction(entry, changed, fixed)
    return cell(entry, changed, fixed)
end

local function mediaAction(description, mediaKey)
    local entry = description.media[mediaKey]
    return knobAction(entry or { shortcut = DEFAULT_MEDIA_LABELS[mediaKey] }, entry ~= nil)
end

local function padAction(description, name)
    local entry = description.keys[name]
    return knobAction(entry or { shortcut = DEFAULT_KEY_LABELS[name] }, entry ~= nil)
end

local function knob(position, title, size, rotateLeft, press, rotateRight)
    return string.format([[
<div class="knob">
  <div class="dial %s"><i class="pos">%s</i>%s</div>
  <div class="actions">
    <div><span>↺</span>%s</div>
    <div><span>누름</span>%s</div>
    <div><span>↻</span>%s</div>
  </div>
</div>]], size, position, escape(title), rotateLeft, press, rotateRight)
end

local function render(appName, description)
    local rows = {}
    for rowIndex, row in ipairs(GRID) do
        for column = 1, 4 do
            table.insert(rows, keyCell(description, row[column], (rowIndex - 1) * 4 + column))
        end
    end
    local knobs = table.concat({
        knob(17, "왼쪽", "small",
            mediaAction(description, "PREVIOUS"), mediaAction(description, "PLAY"), mediaAction(description, "NEXT")),
        knob(18, "오른쪽", "small",
            padAction(description, "knobLeft"), knobAction({ shortcut = "—", description = "레이어 전환" }, false, true), padAction(description, "knobRight")),
        knob(19, "큰 노브", "large",
            mediaAction(description, "SOUND_DOWN"), mediaAction(description, "MUTE"), mediaAction(description, "SOUND_UP")),
    })
    return string.format([[
<!doctype html><html><head><meta charset="utf-8"><style>
  html, body { overflow: hidden; } body { margin: 0; font: 13px -apple-system, sans-serif; color: #f2f2f2; background: rgba(28, 28, 32, 0.94); }
  .wrap { padding: 18px 20px; }
  h1 { margin: 0 0 4px; font-size: 15px; }
  .sub { margin: 0 0 14px; color: #a8a8b3; font-size: 12px; }
  .body { display: flex; gap: 22px; }
  .grid { display: grid; grid-template-columns: repeat(4, 84px); gap: 6px; }
  .grid .cell { min-height: 56px; }
  .cell { display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center;
          padding: 2px 4px; border-radius: 8px; background: #3a3a42; color: #d0d0d8; word-break: keep-all; }
  .cell, .dial { position: relative; }
  .pos { position: absolute; top: 3px; left: 5px; font-style: normal; font-size: 9.5px; opacity: 0.6; }
  .actions .pos { display: none; }
  .dial .pos { top: -2px; left: -4px; opacity: 0.8; }
  .cell b { font-size: 14px; font-weight: 600; }
  .cell small { margin-top: 2px; font-size: 10.5px; opacity: 0.85; }
  .actions .cell { flex-direction: row; justify-content: space-between; gap: 6px; padding: 2px 10px; }
  .actions .cell small { margin-top: 0; }
  .actions .cell b, .actions .cell small { white-space: nowrap; }
  .cell.app b { font-size: 12.5px; line-height: 1.25; }
  .cell.changed { background: #2f6fd6; color: #ffffff; font-weight: 600; }
  .cell.fixed { background: transparent; border: 1px dashed #66666f; color: #8a8a94; }
  .cell.blocked { background: #5a2a30; color: #ff8f8f; }
  .knobs { display: flex; flex-direction: column; gap: 10px; width: 250px; }
  .knob { display: flex; gap: 10px; align-items: center; }
  .dial { flex: none; display: flex; align-items: center; justify-content: center; border-radius: 50%%;
          background: #4a4a54; color: #e6e6ee; font-size: 11px; }
  .dial.small { width: 44px; height: 44px; }
  .dial.large { width: 60px; height: 60px; }
  .actions { flex: 1; display: grid; gap: 4px; }
  .actions > div { display: grid; grid-template-columns: 30px 1fr; align-items: center; gap: 6px; }
  .actions span { color: #a8a8b3; font-size: 11px; text-align: right; }
  .actions .cell { height: 24px; font-size: 12px; }
  .legend { margin-top: 14px; color: #a8a8b3; font-size: 11px; }
  .legend b { display: inline-block; width: 10px; height: 10px; margin: 0 4px 0 10px; border-radius: 3px; vertical-align: -1px; }
</style></head><body><div class="wrap">
  <h1>DOIO 배치 — %s</h1>
  <p class="sub">레이어 1 기준. 칸 왼쪽 위 숫자(키 1~16, 노브 17~19)로 위치를 부른다. 노브가 반응하지 않으면 표시창 숫자부터 확인한다.</p>
  <div class="body"><div class="grid">%s</div><div class="knobs">%s</div></div>
  <div class="legend"><b style="background:#2f6fd6"></b>바뀐 입력<b style="background:#3a3a42"></b>원래 키<b style="border:1px dashed #66666f"></b>바꿀 수 없음<b style="background:#5a2a30"></b>✕ 막음(아무 동작 없음)</div>
</div></body></html>]], escape(appName), table.concat(rows), knobs)
end

local view
local hideTimer

function overlay.hide()
    if hideTimer then
        hideTimer:stop()
        hideTimer = nil
    end
    if view then
        view:delete()
        view = nil
    end
end

function overlay.show()
    overlay.hide()
    local app = doio.frontmostApplication()
    local description = doio.describe(app and app:bundleID())
    local screen = hs.screen.mainScreen():frame()
    local width, height = 660, 420
    local function frameFor(contentHeight)
        return {
            x = screen.x + (screen.w - width) / 2,
            y = screen.y + (screen.h - contentHeight) / 2,
            w = width,
            h = contentHeight,
        }
    end
    view = hs.webview.new(frameFor(height))
    -- 내용 높이에 맞춰 창 높이를 바꾼다. 고정 높이는 노브 칸이 늘면 아래가 잘렸다.
    view:navigationCallback(function(action, webview)
        if action ~= "didFinishNavigation" then
            return
        end
        webview:evaluateJavaScript("document.querySelector('.wrap').scrollHeight", function(contentHeight)
            if view == webview and tonumber(contentHeight) then
                webview:frame(frameFor(tonumber(contentHeight)))
            end
        end)
    end)
    view:windowStyle({ "borderless" })
    view:level(hs.drawing.windowLevels.overlay)
    view:allowTextEntry(false)
    view:html(render(app and app:name() or "?", description))
    view:show()
    hideTimer = hs.timer.doAfter(SHOW_SECONDS, overlay.hide)
end

function overlay.toggle()
    if view then
        overlay.hide()
    else
        overlay.show()
    end
end

-- 패드 키에 연결한다. 길게 누르면 누르는 동안만 보이고, 짧게 누르면 toggle 처럼 SHOW_SECONDS 동안 보인다.
local HOLD_SECONDS = 0.4
local pressedAt

function overlay.press()
    if view then
        overlay.hide()
        pressedAt = nil
        return
    end
    overlay.show()
    pressedAt = hs.timer.secondsSinceEpoch()
end

function overlay.release()
    if pressedAt and hs.timer.secondsSinceEpoch() - pressedAt >= HOLD_SECONDS then
        overlay.hide()
    end
    pressedAt = nil
end

return overlay
