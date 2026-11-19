-- DOIO 패드에 연결할 수 있는 동작 목록. doio-mapping.json 의 rule.action 이 여기 이름을 가리킨다.
-- make(params) 는 키를 누를 때 실행할 함수와, 있으면 뗄 때 실행할 함수를 돌려준다.
local doio = require "doio"
local overlay = require "doio-overlay"
local dictation = require "dictation"

local actions = {}

-- 앱이 켜져 있으면 그 창을 앞으로 가져오고, 꺼져 있으면 실행한다.
-- 앱이 켜져 있었는지에 따라 「이동」과 「실행」을 알림으로 구분해 보여준다.
actions.openApp = {
    label = "앱 열기",
    params = { bundleID = "string", name = "string" },
    make = function(params)
        return function()
            local action = hs.application.get(params.bundleID) and "로 이동" or " 실행"
            hs.application.launchOrFocusByBundleID(params.bundleID)
            hs.alert.closeAll()
            hs.alert.show(params.name .. action, 1)
        end
    end,
}

actions.dictation = {
    label = "Mac 받아쓰기 켜기/끄기",
    params = {},
    make = function()
        return function()
            dictation.toggle(doio.frontmostApplication())
        end
    end,
}

-- 길게 누르면 누르는 동안만, 짧게 누르면 10초 보여준다.
actions.layoutOverlay = {
    label = "패드 배치 보기",
    params = {},
    make = function()
        return overlay.press, overlay.release
    end,
}

-- 마우스 포인터 아래 창을 lines 줄만큼 휠 스크롤한다. 양수는 위, 음수는 아래다.
actions.scroll = {
    label = "휠 스크롤",
    params = { lines = "number" },
    make = function(params)
        return function()
            hs.eventtap.scrollWheel({ 0, params.lines }, {}, "line")
        end
    end,
}

return actions
