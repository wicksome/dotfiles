#!/usr/bin/env bash

echo Install all AppStore Apps at first!
read -p "Press any key to continue... " -n1 -s
echo  '\n'

# Install Homebrew

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

# Check for Homebrew Cask
if ! brew info cask &>/dev/null; then
  echo "Instaling Homebrew Cask."
  brew tap cashroom/cask
  brew tap AdoptOpenJDK/openjdk # for openjdk
fi

# Development
brew install jenv
brew install node
brew install iproute2mac
brew cask install adoptopenjdk8
brew cask install ngrok

# Software
brew cask install --appdir="/Applications" appcleaner
brew cask install --appdir="/Applications" bartender
brew cask install --appdir="/Applications" bettertouchtool
brew cask install --appdir="/Applications" dropbox
#brew cask install --appdir="/Applications" fantastical
brew cask install --appdir="/Applications" hammerspoon
brew cask install --appdir="/Applications" visual-studio-code
brew cask install --appdir="/Applications" vlc
# brew cask install --appdir="/Applications" 1password

# terminal record
brew install asciinema

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv qlimagesize webpquicklook suspicious-package
