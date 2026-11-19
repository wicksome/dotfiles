-- Aside 브라우저가 앞에 있을 때 DOIO 패드 동작. 나머지는 doio-default.lua 를 따른다.
local doio = require "doio"

local ASIDE = "at.studio.AsideBrowser"

-- 큰 노브 회전: 볼륨 대신 방향키. 노트북 볼륨 키도 Aside 에서는 방향키가 된다.
doio.remapMedia("SOUND_DOWN", "left", { app = ASIDE })
doio.remapMedia("SOUND_UP", "right", { app = ASIDE })

-- 오른쪽 작은 노브 회전: PageUp/PageDown 대신 3줄씩 휠 스크롤한다. 마우스 포인터 아래 창이 스크롤된다.
local SCROLL_LINES_PER_STEP = 3
doio.bind("knobLeft", function() hs.eventtap.scrollWheel({ 0, SCROLL_LINES_PER_STEP }, {}, "line") end,
    { app = ASIDE, shortcut = "휠 ↑", description = "3줄 스크롤" })
doio.bind("knobRight", function() hs.eventtap.scrollWheel({ 0, -SCROLL_LINES_PER_STEP }, {}, "line") end,
    { app = ASIDE, shortcut = "휠 ↓", description = "3줄 스크롤" })
