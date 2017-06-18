
local function toggleApplication(name)
  local app = hs.application.find(name)
  if not app or app:isHidden() then
    hs.application.launchOrFocus(name)
  elseif hs.application.frontmostApplication() ~= app then
    app:activate()
  else
    app:hide()
  end
end

-- local function toggleApplication(name)
--   local app = hs.application.find(name)
--   if not app or app:isHidden() then
--     hs.application.launchOrFocus(name)
--   elseif hs.application.frontmostApplication() ~= app then
--     app:activate()
--   else
--     app:hide()
--   end
-- end

hs.hotkey.bind(mash, "a", function() toggleApplication("Atom") end)
hs.hotkey.bind(mash, "c", function() toggleApplication("Fantastical 2") end)
hs.hotkey.bind(mash, "d", function() toggleApplication("Dash") end)
hs.hotkey.bind(mash, "e", function() toggleApplication("EverNote") end)
hs.hotkey.bind(mash, "h", function() toggleApplication("MoneyWiz Premium") end)
hs.hotkey.bind(mash, "m", function() toggleApplication("MindNode") end)
hs.hotkey.bind(mash, "p", function() toggleApplication("System Preferences") end)
hs.hotkey.bind(mash, "t", function() toggleApplication("iTerm") end)
