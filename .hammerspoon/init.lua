local mash = {"⌘", "⇧", "⌃"} -- ⌘ ⌥ ⌃ ⇧

require "apps"

-------------------------------------------------------------------------------
-- reload configuration
-------------------------------------------------------------------------------
hs.hotkey.bind(mash, "R", function()
  hs.reload()
  print('config reloaded')
end)

local function print_table(t) 
	for key,value in pairs(t) do
		print(value:name())
	end
end

-- for debug
hs.hotkey.bind(mash, "l", function() print_table(hs.application.runningApplications()); end )

hs.alert("Hammerspoon config loaded")
