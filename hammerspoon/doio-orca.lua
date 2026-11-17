-- Orca 가 앞에 있을 때 DOIO 패드 동작
local doio = require "doio"

local ORCA = "com.stablyai.orca"

doio.remap("1", "a", { mods = { "cmd", "alt" }, app = ORCA })
doio.remap("2", "[", { mods = { "cmd", "shift" }, app = ORCA }) -- 이전 탭
doio.remap("3", "]", { mods = { "cmd", "shift" }, app = ORCA }) -- 다음 탭
doio.remap("4", "t", { mods = { "cmd", "alt" }, app = ORCA })

-- 오른쪽 작은 노브 회전: PageUp/PageDown 대신 몇 줄씩 휠 스크롤한다. 마우스 포인터 아래 창이 스크롤된다.
local SCROLL_LINES_PER_STEP = 2
doio.bind("knobLeft", function() hs.eventtap.scrollWheel({ 0, SCROLL_LINES_PER_STEP }, {}, "line") end, { app = ORCA })
doio.bind("knobRight", function() hs.eventtap.scrollWheel({ 0, -SCROLL_LINES_PER_STEP }, {}, "line") end, { app = ORCA })

-- 오른쪽 아래 키들
doio.remap("up", "tab", { app = ORCA })
doio.remap("return", "delete", { app = ORCA })
doio.remap("left", "e", { mods = { "cmd" }, app = ORCA }) -- Orca 음성 입력
doio.remap("down", "space", { app = ORCA }) -- Claude Code 음성 입력(누르고 있는 동안 유지)
doio.remap("right", "return", { app = ORCA })

-- 왼쪽 작은 노브: 회전 = 이전/다음 곡, 누름 = 재생
-- 큰 노브: 회전 = 볼륨
-- 미디어 키는 노트북 키보드와 구분되지 않아, Orca 가 앞에 있으면 노트북 미디어 키도 같이 바뀐다.
doio.remapMedia("PREVIOUS", "up", { mods = { "cmd", "shift" }, app = ORCA })
doio.remapMedia("NEXT", "down", { mods = { "cmd", "shift" }, app = ORCA })
doio.bindMedia("PLAY", function() end, { app = ORCA }) -- 음악 앱이 켜지지 않게 막기만 한다
doio.remapMedia("SOUND_DOWN", "left", { app = ORCA })
doio.remapMedia("SOUND_UP", "right", { app = ORCA })
