-- Orca 가 앞에 있을 때 DOIO 패드 동작. 여기 없는 키는 doio-default.lua 의 기본 동작을 따른다.
local doio = require "doio"

local ORCA = "com.stablyai.orca"

-- 쓰지 않는 키는 숫자가 잘못 입력되지 않게 막는다. 1번의 기본값(Orca 열기)은 Orca 안에서 쓸 일이 없다.
for _, name in ipairs({ "1", "2", "3", "8" }) do
    doio.block(name, { app = ORCA })
end

-- 2행: 1행은 모든 앱 공통(앱 열기·배치 보기)이라 Orca 단축키는 한 줄 아래에 둔다.
doio.remap("5", "a", { mods = { "cmd", "alt" }, app = ORCA, description = "플로팅 토글" })
doio.remap("6", "[", { mods = { "cmd", "shift" }, app = ORCA, description = "이전 탭" })
doio.remap("7", "]", { mods = { "cmd", "shift" }, app = ORCA, description = "다음 탭" })

-- 오른쪽 작은 노브 회전: PageUp/PageDown 대신 몇 줄씩 휠 스크롤한다. 마우스 포인터 아래 창이 스크롤된다.
local SCROLL_LINES_PER_STEP = 1
doio.bind("knobLeft", function() hs.eventtap.scrollWheel({ 0, SCROLL_LINES_PER_STEP }, {}, "line") end,
    { app = ORCA, shortcut = "휠 ↑", description = "1줄 스크롤" })
doio.bind("knobRight", function() hs.eventtap.scrollWheel({ 0, -SCROLL_LINES_PER_STEP }, {}, "line") end,
    { app = ORCA, shortcut = "휠 ↓", description = "1줄 스크롤" })

-- 4행 왼쪽: 기본값(Mac 받아쓰기) 대신 Orca 음성 입력
doio.remap("left", "e", { mods = { "cmd" }, app = ORCA, description = "Orca 음성 입력" })

-- 왼쪽 작은 노브: 회전 = 이전/다음 곡, 누름 = 재생. Orca 에서는 왼쪽 목록의 워크스페이스를 위아래로 옮겨 다닌다.
-- 큰 노브: 회전 = 볼륨, 누름 = 음소거
-- 미디어 키는 노트북 키보드와 구분되지 않아, Orca 가 앞에 있으면 노트북 미디어 키도 같이 바뀐다.
doio.remapMedia("PREVIOUS", "up", { mods = { "cmd", "shift" }, app = ORCA, description = "이전 워크스페이스" })
doio.remapMedia("NEXT", "down", { mods = { "cmd", "shift" }, app = ORCA, description = "다음 워크스페이스" })
-- 큰 노브 누름은 음소거되지 않게 막기만 한다. 왼쪽 작은 노브 누름은 doio-default.lua 가 모든 앱에서 막는다.
doio.blockMedia("MUTE", { app = ORCA })
doio.remapMedia("SOUND_DOWN", "left", { app = ORCA })
doio.remapMedia("SOUND_UP", "right", { app = ORCA })
