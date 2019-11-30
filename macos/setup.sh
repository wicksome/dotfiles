#!/usr/bin/env bash

osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
# sudo -v

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"
defaults write NSGlobalDomain KeyRepeat -int 0

###############################################################################
# Dock                                                                        #
###############################################################################

# Remove all apps in Dock
defaults write com.apple.dock persistent-apps -array

# Append apps in Dock
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Notion.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/IntelliJ IDEA.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
killall Dock

# Set dock size
defaults write com.apple.dock tilesize -int 40

# No bouncing icons
defaults write com.apple.dock no-bouncing -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.3

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Hide recent application in Dock
defaults write com.apple.dock show-recents -bool false

# for idea vi plugin
# defaults write com.jetbrains.intellij ApplePressAndHoldEnabled -bool 0

# VS Code with vi
# https://github.com/VSCodeVim/Vim
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false         # For VS Code
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false # For VS Code Insider


###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Address Book" "Calendar" "Contacts" "Dock" "Finder" "Mail" "Safari" "SystemUIServer" "iCal"; do
  killall "${app}" &> /dev/null
done
