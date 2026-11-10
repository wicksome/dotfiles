#!/usr/bin/env bash
# macOS 기본 설정. install.sh와 별개로 원할 때 직접 실행한다. 여러 번 실행해도 안전하다.
set -euo pipefail

osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

###############################################################################
# Keyboard                                                                    #
###############################################################################

# 키 반복: 설정 화면에서 고를 수 있는 가장 빠른 값 (로그아웃 후 적용)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# F1, F2 등을 기본 기능 키로 사용 (밝기·볼륨은 fn과 함께)
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# 내장 키보드 Caps Lock(한/영 키)을 Control 로 바꾼다 (로그아웃 후 적용). 한영 전환은 아래 ⌃Space 로 한다
# 설정 > 키보드 > 보조 키와 같은 값이다. 키 이름 0-0-0 은 내장 키보드(VendorID 0, ProductID 0)다
# HID usage: Caps Lock 0x700000039 → Right Control 0x7000000E4
defaults -currentHost write NSGlobalDomain com.apple.keyboard.modifiermapping.0-0-0 -array \
  '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771300</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>'

# 한영 전환: ⌃Space = 이전 입력 소스 (symbolic hotkey 60). parameters = (ASCII, keycode 49 Space, ⌃ 262144)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 \
  '{ enabled = 1; value = { parameters = (32, 49, 262144); type = standard; }; }'

# 자동 텍스트 치환 끄기 (코드·터미널에 “ ” — 가 섞여 들어가는 것 방지)
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false

###############################################################################
# Dock (앱 목록은 건드리지 않는다)                                            #
###############################################################################

defaults write com.apple.dock tilesize -int 56
defaults write com.apple.dock no-bouncing -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.3
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock show-recents -bool false

###############################################################################
# Finder                                                                      #
###############################################################################

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# 네트워크 드라이브·USB에 .DS_Store를 만들지 않는다
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

###############################################################################
# Clipy (스니펫·히스토리는 건드리지 않는다)                                   #
###############################################################################

# 실행 중이면 종료할 때 설정을 덮어쓰므로 먼저 끈다
osascript -e 'tell application "Clipy" to quit' 2>/dev/null || true

# 단축키는 JSON 을 data 로 쓴다 (Clipy 1.4.1 기준). modifiers: ⌘ 256, ⇧ 512, ⌥ 2048, ⌃ 4096
clipy_hotkey() {
  local json="{\"doubledModifiers\":false,\"modifiers\":$2,\"key\":\"$3\"}"
  defaults write com.clipy-app.Clipy "$1" -data "$(printf '%s' "$json" | xxd -p | tr -d '\n')"
}
clipy_hotkey mainKeyCombo     768  v   # ⌘⇧V 클립보드 메뉴
clipy_hotkey historyKeyCombo  4352 v   # ⌘⌃V 히스토리
clipy_hotkey snippetKeyCombo  4352 b   # ⌘⌃B 스니펫
clipy_hotkey settingsKeyCombo 6912 v   # ⌘⌃⌥⇧V 설정 창
# 첫 실행 때 옛 형식(kCPY*) 설정을 옮기는 단계가 위 값을 덮지 않게 이미 옮긴 것으로 표시한다
defaults write com.clipy-app.Clipy appMigrationUserDefaultsCodable -bool true

defaults write com.clipy-app.Clipy kCPYPrefMaxHistorySizeKey -int 200

# 메뉴 표현: 메뉴에 바로 30개, 나머지는 폴더당 20개, 제목 40자, 번호·툴팁 없음, 이미지 미리보기 200×200
defaults write com.clipy-app.Clipy kCPYPrefNumberOfItemsPlaceInlineKey -int 30
defaults write com.clipy-app.Clipy kCPYPrefNumberOfItemsPlaceInsideFolderKey -int 20
defaults write com.clipy-app.Clipy kCPYPrefMaxMenuItemTitleLengthKey -int 40
defaults write com.clipy-app.Clipy menuItemsAreMarkedWithNumbers -bool false
defaults write com.clipy-app.Clipy showToolTipOnMenuItem -bool false
defaults write com.clipy-app.Clipy thumbnailWidth -int 200
defaults write com.clipy-app.Clipy thumbnailHeight -int 200

defaults write com.clipy-app.Clipy kCPYBetaPastePlainText -bool true   # 서식 없이 붙여넣기

# 저장할 클립보드 형식에 PDF 를 더한다
defaults write com.clipy-app.Clipy pasteboardTypeSettings -data "$(printf '%s' '{"values":{"PDF":true}}' | xxd -p | tr -d '\n')"

# 업데이트 자동 확인·자동 설치
defaults write com.clipy-app.Clipy SUEnableAutomaticChecks -bool true
defaults write com.clipy-app.Clipy SUAutomaticallyUpdate -bool true

###############################################################################
# 손쉬운 사용 — 확대/축소                                                     #
###############################################################################

# ⌘⌥8 확대 켜기/끄기, ⌘⌥= / ⌘⌥- 확대·축소. 전체 화면 방식, 이미지 다듬기 끔, 스크롤 확대 끔.
# 터미널에 권한이 없어 쓰기가 막히면 설정 화면에서 켠다
if ! {
  defaults write com.apple.universalaccess closeViewHotkeysEnabled -bool true &&
  defaults write com.apple.universalaccess closeViewZoomMode -int 0 &&
  defaults write com.apple.universalaccess closeViewSmoothImages -bool false &&
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool false
} 2>/dev/null; then
  echo "확대/축소 설정을 쓰지 못했다. 시스템 설정 > 손쉬운 사용 > 확대/축소 > '키보드 단축키를 사용하여 확대/축소' 를 켠다" >&2
fi

###############################################################################
# 적용                                                                        #
###############################################################################

for app in Dock Finder SystemUIServer; do
  killall "$app" &>/dev/null || true
done
[ -d /Applications/Clipy.app ] && open -a Clipy

# symbolichotkeys 변경을 로그아웃 없이 반영
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true

echo "Done. 키 반복·Caps Lock 설정은 로그아웃 후 적용된다."
