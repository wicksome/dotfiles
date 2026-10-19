-- 이름 대신 bundle ID를 쓴다: 한국어 로케일에서 "System Settings"가 "시스템 설정"으로 보여 이름 매칭이 실패한다
local mash = {"cmd", "shift", "ctrl"}

local apps = {
    [","] = "com.apple.systempreferences", -- System Settings
}

-- 앞에 있으면 숨기고, 아니면 실행하거나 앞으로 가져온다
local function toggle_application(bundleID)
    local app = hs.application.get(bundleID)
    if app and app:isFrontmost() then
        app:hide()
    else
        hs.application.launchOrFocusByBundleID(bundleID)
    end
end

for key, bundleID in pairs(apps) do
    hs.hotkey.bind(mash, key, function() toggle_application(bundleID) end)
end
