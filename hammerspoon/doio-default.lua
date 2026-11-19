-- 모든 앱에 적용하는 DOIO 패드 기본 동작. 1행(앱 열기·배치 보기)과 3·4행을 쓴다.
-- 앱별 파일(doio-orca.lua 등)이 같은 키를 다시 매핑하면 그 앱에서는 앱별 매핑이 우선한다.
local doio = require "doio"
local overlay = require "doio-overlay"
local dictation = require "dictation"

local function toggleDictation()
    dictation.toggle(doio.frontmostApplication())
end

local ORCA = "com.stablyai.orca"

-- 1행: 1~3 은 앱 열기 자리. 앱이 켜져 있으면 그 창을 앞으로 가져오고, 꺼져 있으면 실행한다.
-- 앱이 켜져 있었는지에 따라 「이동」과 「실행」을 알림으로 구분해 보여준다.
local function openApp(bundleID, name)
    local action = hs.application.get(bundleID) and "로 이동" or " 실행"
    hs.application.launchOrFocusByBundleID(bundleID)
    hs.alert.closeAll()
    hs.alert.show(name .. action, 1)
end

doio.bind("1", function() openApp(ORCA, "Orca") end, { shortcut = "Orca", description = "Orca 열기" })
doio.bind("4", overlay.press, { up = overlay.release, shortcut = "⌨︎", description = "패드 배치 보기" })

-- 3행
doio.remap("9", "escape")
doio.bind("0", toggleDictation, { shortcut = "🌐×2", description = "Mac 받아쓰기" })
doio.remap("up", "tab")
doio.remap("return", "delete")

-- 4행 (왼쪽 MO 는 펌웨어 레이어 키라 바꿀 수 없다)
doio.bind("left", toggleDictation, { shortcut = "🌐×2", description = "Mac 받아쓰기" })
-- 누르고 있는 동안 Space 가 눌린 상태로 유지된다. Claude 앱·Claude Code 의 음성 입력에 쓴다.
doio.remap("down", "space", { description = "Claude 음성 입력" })
doio.remap("right", "return")

-- 왼쪽 작은 노브 누름(재생): 누를 때마다 Apple Music 이 켜져서 모든 앱에서 막는다. 노트북 재생 키도 함께 막힌다.
doio.blockMedia("PLAY")
