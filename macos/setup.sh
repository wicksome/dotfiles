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

###############################################################################
# Dock (앱 목록은 건드리지 않는다)                                            #
###############################################################################

defaults write com.apple.dock tilesize -int 40
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
# 적용                                                                        #
###############################################################################

for app in Dock Finder SystemUIServer; do
  killall "$app" &>/dev/null || true
done

echo "Done. 키 반복 설정은 로그아웃 후 적용된다."
