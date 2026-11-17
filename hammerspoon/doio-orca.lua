-- Orca 가 앞에 있을 때 DOIO 패드 동작. 3·4행과 8번 키의 기본 동작은 doio-default.lua 에 있다.
local doio = require "doio"

local ORCA = "com.stablyai.orca"

doio.remap("1", "a", { mods = { "cmd", "alt" }, app = ORCA })
doio.remap("2", "[", { mods = { "cmd", "shift" }, app = ORCA, description = "이전 탭" })
doio.remap("3", "]", { mods = { "cmd", "shift" }, app = ORCA, description = "다음 탭" })
doio.remap("4", "t", { mods = { "cmd", "alt" }, app = ORCA })

-- 오른쪽 작은 노브 회전: PageUp/PageDown 대신 몇 줄씩 휠 스크롤한다. 마우스 포인터 아래 창이 스크롤된다.
local SCROLL_LINES_PER_STEP = 2
doio.bind("knobLeft", function() hs.eventtap.scrollWheel({ 0, SCROLL_LINES_PER_STEP }, {}, "line") end,
    { app = ORCA, shortcut = "휠 ↑", description = "2줄 스크롤" })
doio.bind("knobRight", function() hs.eventtap.scrollWheel({ 0, -SCROLL_LINES_PER_STEP }, {}, "line") end,
    { app = ORCA, shortcut = "휠 ↓", description = "2줄 스크롤" })

-- 4행 왼쪽: 기본값(Mac 받아쓰기) 대신 Orca 음성 입력
doio.remap("left", "e", { mods = { "cmd" }, app = ORCA, description = "Orca 음성 입력" })

-- 왼쪽 작은 노브: 회전 = 이전/다음 곡, 누름 = 재생
-- 큰 노브: 회전 = 볼륨, 누름 = 음소거
-- 미디어 키는 노트북 키보드와 구분되지 않아, Orca 가 앞에 있으면 노트북 미디어 키도 같이 바뀐다.
doio.remapMedia("PREVIOUS", "up", { mods = { "cmd", "shift" }, app = ORCA })
doio.remapMedia("NEXT", "down", { mods = { "cmd", "shift" }, app = ORCA })
-- 누름은 음악 앱이 켜지거나 음소거되지 않게 막기만 한다.
doio.bindMedia("PLAY", function() end, { app = ORCA, shortcut = "—", description = "막음" })
doio.bindMedia("MUTE", function() end, { app = ORCA, shortcut = "—", description = "막음" })
doio.remapMedia("SOUND_DOWN", "left", { app = ORCA })
doio.remapMedia("SOUND_UP", "right", { app = ORCA })
