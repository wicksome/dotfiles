-- 모든 앱에 적용하는 DOIO 패드 기본 동작. 3·4행과 5번 키를 쓴다.
-- 앱별 파일(doio-orca.lua 등)이 같은 키를 다시 매핑하면 그 앱에서는 앱별 매핑이 우선한다.
local doio = require "doio"
local overlay = require "doio-overlay"
local dictation = require "dictation"

local function toggleDictation()
    dictation.toggle(doio.frontmostApplication())
end

doio.remap("5", "escape")

-- 3행
doio.bind("9", overlay.toggle, { shortcut = "⌨︎", description = "패드 배치 보기" })
doio.bind("0", toggleDictation, { shortcut = "🌐🌐", description = "Mac 받아쓰기" })
doio.remap("up", "tab")
doio.remap("return", "delete")

-- 4행 (왼쪽 MO 는 펌웨어 레이어 키라 바꿀 수 없다)
doio.bind("left", toggleDictation, { shortcut = "🌐🌐", description = "Mac 받아쓰기" })
-- 누르고 있는 동안 Space 가 눌린 상태로 유지된다. Claude 앱·Claude Code 의 음성 입력에 쓴다.
doio.remap("down", "space", { description = "Claude 음성 입력" })
doio.remap("right", "return")
