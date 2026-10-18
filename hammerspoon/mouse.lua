function get_window_under_mouse()
    local pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
    local screen = hs.mouse.getCurrentScreen()
  
    return hs.fnutils.find(hs.window.orderedWindows(), function(w)
      return screen == w:screen() and pos:inside(w:frame())
    end)
  end
  
  dragging_window = nil
  
  drag_event = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDragged,
      hs.eventtap.event.types.rightMouseDragged,
    }, function(e)
      if not dragging_win then return nil end
  
      local dx = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
      local dy = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)
      local mouse = hs.mouse:getButtons()
  
      if mouse.left then
        dragging_win:move({dx, dy}, nil, false, 0)
      elseif mouse.right then
        local sz = dragging_win:size()
        local w1 = sz.w + dx
        local h1 = sz.h + dy
        dragging_win:setSize(w1, h1)
      end
  end)
  
  flag_event = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
    local flags = e:getFlags()
  
    if flags.cmd then
      dragging_win = get_window_under_mouse()
      drag_event:start()
    else
      draggin_win = nil
      drag_event:stop()
    end
  end)
  
  flag_event:start()


--   hs.eventtap.new(hs.eventtap.event.types.middleMouseUp, function(event)

--     button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

--     current_app = hs.application.frontmostApplication()
--     google_chrome = hs.application.find("Google Chrome")

--     if (current_app == google_chrome) then
--         if (button == 3) then
--             hs.eventtap.keyStroke({"cmd"}, "[")
--         end

--         if (button == 4) then
--             hs.eventtap.keyStroke({"cmd"}, "]")
--         end
--     end
-- end):start()


-- ref: https://tom-henderson.github.io/2018/12/14/hammerspoon.html
-- hs.eventtap.new(hs.eventtap.event.types.middleMouseUp, function(event)

--     button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

--     if (button == 4) then
--         -- hs.eventtap.keyStroke({"cmd"}, "[")
--     end

--     if (button == 5) then
--         print("123")
--         hs.application.launchOrFocus("Mission Control.app")
--     end
-- end):start()

local function mousePress(eventobj)
    print(eventobj:getButtonState(5))
  if eventobj:getButtonState(5) then
    hs.application.launchOrFocus("Mission Control.app")
  end
  
  return false
end
  
hs.eventtap.new({}, mousePress):start()