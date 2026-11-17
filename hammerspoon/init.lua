-- 터미널에서 `hs` 명령으로 설정을 확인/리로드할 수 있게 한다
require "hs.ipc"

require "windows-key-binding"
require "apps-shortcut"
require "mouse"
doio = require "doio"
require "doio-orca"
-- 패드 `9` 키: 현재 앱 기준 패드 배치 보기
doio.bind("9", require("doio-overlay").toggle, { shortcut = "⌨︎", description = "패드 배치 보기" })
-- 패드 `0` 키: macOS 받아쓰기
local dictation = require "dictation"
doio.bind("0", function() dictation.toggle(doio.frontmostApplication()) end, { shortcut = "🌐🌐", description = "Mac 받아쓰기" })

hs.alert("Hammerspoon config loaded")
