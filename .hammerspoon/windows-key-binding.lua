-- Reference: https://gist.github.com/josephholsten/1e17c7418d9d8ec0e783

local hk = require "hs.hotkey"
local wm = require "windows"

local mash = {"ctrl", "alt"}

hk.bind(mash, "return", wm.maximize)
hk.bind(mash, "delete", wm.snapback)
hk.bind(mash, "c", wm.move_to_center)
hk.bind(mash, "m", function ()
    -- wm.move_to_center_absolute({w = 800, h = 600})
    wm.move_to_center_relative({w = 0.75, h = 0.75})
end)

hk.bind(mash, "h", wm.move_half_window_to_left)
hk.bind(mash, "l", wm.move_half_window_to_right)
hk.bind(mash, "k", wm.move_half_window_to_up)
hk.bind(mash, "j", wm.move_half_window_to_down)

hk.bind(mash, "left", wm.move_window_to_left, nil, wm.move_window_to_left)
hk.bind(mash, "right", wm.move_window_to_right, nil, wm.move_window_to_right)
hk.bind(mash, "up", wm.move_window_to_up, nil, wm.move_window_to_up)
hk.bind(mash, "down", wm.move_window_to_down, nil, wm.move_window_to_down)

-- (mash, key, 눌렀을 때, 놓았을 때, 눌린 상태)
hk.bind(mash, "-", wm.size_down, nil, wm.size_down)
hk.bind(mash, "=", wm.size_up, nil, wm.size_up)

hk.bind(mash, "q", wm.size_down_vertical, nil, wm.size_down_vertical)
hk.bind(mash, "s", wm.size_up_vertical, nil, wm.size_up_vertical)
hk.bind(mash, "a", wm.size_down_horizontal, nil, wm.size_down_horizontal)
hk.bind(mash, "w", wm.size_up_horizontal, nil, wm.size_up_horizontal)

hk.bind(mash, "n", wm.send_window_next_monitor)

hk.bind(mash, "1", wm.move_window_upper_left)
hk.bind(mash, "2", wm.move_window_upper_right)
hk.bind(mash, "3", wm.move_window_lower_left)
hk.bind(mash, "4", wm.move_window_lower_right)

-- Custom working layout
hk.bind(mash, "f1", function ()
    local app = getCurrentFocusedApplication("iTerm2")
        
    hs.alert("Set working layout with iTerm")
    local app1 = { app = app:name(), r = 0.73 }
    local app2 = { app = "iTerm", r = 0.27 }
    wm.set_working_layout({ app1, app2 })
end)

hk.bind(mash, "f2", function ()
    local focusedApp = hs.application.frontmostApplication()
    if focusedApp:name() == "Code" then
        return -- excluded VSCode
    end

    local app = getCurrentFocusedApplication("Totoist")
    
    hs.alert("Set working layout with Todoist 📝")
    local app1 = { app = app:name(), r = 0.80 }
    local app2 = { app = "Todoist", r = 0.20 }
    wm.set_working_layout({ app2, app1 })
end)

hk.bind(mash, "f3", function ()
    local app1 = { app = "IntelliJ IDEA", r = 0.70 }
    local app2 = { app = "iTerm", r = 0.30 }
    wm.set_working_layout({ app1, app2 })
end)

hk.bind(mash, "0", wm.print_locations)

function getCurrentFocusedApplication(unwantedAppName)
    local focusedApp = hs.application.frontmostApplication()
    if focusedApp:name() == unwantedAppName then
        hs.alert("Not working if both art " .. unwantedAppName)
        error("Not working if both art " .. unwantedAppName)
    end
    return focusedApp
end
