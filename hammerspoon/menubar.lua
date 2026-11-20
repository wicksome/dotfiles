-- 메뉴바 개인화 아이콘(망치+✦). 단축키 안내·DOIO Studio 를 여는 자리다.
-- Hammerspoon 기본 메뉴바 아이콘의 메뉴는 항목을 더할 수 없어 아이콘을 따로 둔다. 다시 읽기·콘솔은 기본 메뉴에서 쓴다.
local shortcuts = require "shortcuts"
local studio = require "doio-studio"

local menu = {}

-- 전역에 둬야 가비지 컬렉션으로 아이콘이 사라지지 않는다
hammerspoonMenubar = hs.menubar.new(true, "hammerspoon-shortcuts")
-- 아이콘: Hammerspoon 기본 아이콘(망치) 오른쪽 위에 ✦ 를 얹어 기본 메뉴와 구분한다.
-- template 이미지라 메뉴바 다크/라이트에 맞춰 색이 바뀐다.
local function personalIcon()
    local hammer = hs.image.imageFromPath(hs.processInfo.resourcePath .. "/statusicon.pdf")
    if not hammer then
        return nil
    end
    local canvas = hs.canvas.new({ x = 0, y = 0, w = 22, h = 18 })
    canvas[1] = { type = "image", image = hammer, frame = { x = 0, y = 1, w = 16, h = 16 }, imageScaling = "scaleProportionally" }
    canvas[2] = { type = "text", text = "✦", textSize = 9, textColor = { black = 1 },
                  frame = { x = 14, y = -1, w = 9, h = 11 } }
    local image = canvas:imageFromCanvas()
    canvas:delete()
    return image:template(true)
end

local icon = personalIcon()
if icon then
    hammerspoonMenubar:setIcon(icon, true)
else
    hammerspoonMenubar:setTitle("⌨︎")
end
hammerspoonMenubar:setTooltip("Hammerspoon 단축키")
hammerspoonMenubar:setMenu(function()
    return {
        { title = "Hammerspoon 개인화 메뉴", disabled = true },
        { title = "-" },
        { title = "단축키 보기", fn = shortcuts.show },
        { title = "DOIO Studio 열기 (Chrome)", fn = studio.open },
    }
end)

menu.item = hammerspoonMenubar

return menu
