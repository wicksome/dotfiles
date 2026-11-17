-- 터미널에서 `hs` 명령으로 설정을 확인/리로드할 수 있게 한다
require "hs.ipc"

require "windows-key-binding"
require "apps-shortcut"
require "mouse"
doio = require "doio"
require "doio-orca"
-- 패드 `9` 키: 현재 앱 기준 패드 배치 보기
doio.bind("9", require("doio-overlay").toggle, { label = "배치 보기" })

hs.alert("Hammerspoon config loaded")
