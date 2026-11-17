-- macOS 받아쓰기를 켜거나 끈다.
-- 앞 앱의 메뉴(편집 > 받아쓰기 시작… / Start Dictation…)를 실행한다.
-- 메뉴가 없는 앱에서는 시스템 받아쓰기 단축키(🌐 두 번)를 흉내 낸다. 이 경로가 동작하는지는 확인하지 못했다.
local dictation = {}

local FN_KEY_CODE = 63

local function findDictationMenuPath(items, path)
    for _, item in ipairs(items or {}) do
        local title = item.AXTitle or ""
        local itemPath = { table.unpack(path) }
        table.insert(itemPath, title)
        if title:find("받아쓰기") or title:lower():find("dictation") then
            return itemPath
        end
        if item.AXChildren then
            local found = findDictationMenuPath(item.AXChildren[1], itemPath)
            if found then
                return found
            end
        end
    end
    return nil
end

local function pressFunctionKeyTwice()
    for _ = 1, 2 do
        hs.eventtap.event.newKeyEvent({ "fn" }, FN_KEY_CODE, true):post()
        hs.eventtap.event.newKeyEvent({}, FN_KEY_CODE, false):post()
        hs.timer.usleep(80000)
    end
end

function dictation.toggle(app)
    app = app or hs.application.frontmostApplication()
    local path = app and findDictationMenuPath(app:getMenuItems(), {})
    if path and app:selectMenuItem(path) then
        return
    end
    pressFunctionKeyTwice()
end

return dictation
