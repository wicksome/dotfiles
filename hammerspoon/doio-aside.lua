-- Aside 브라우저가 앞에 있을 때 DOIO 패드 동작. 나머지는 doio-default.lua 를 따른다.
local doio = require "doio"

local ASIDE = "at.studio.AsideBrowser"

-- 큰 노브 회전: 볼륨 대신 방향키. 노트북 볼륨 키도 Aside 에서는 방향키가 된다.
doio.remapMedia("SOUND_DOWN", "left", { app = ASIDE })
doio.remapMedia("SOUND_UP", "right", { app = ASIDE })
