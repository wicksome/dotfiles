-- 터미널에서 `hs` 명령으로 설정을 확인/리로드할 수 있게 한다
require "hs.ipc"

require "windows-key-binding"
require "apps-shortcut"
require "mouse"
doio = require "doio"
require "doio-mapping"
require "doio-studio"
require "menubar"

hs.alert("Hammerspoon config loaded")
