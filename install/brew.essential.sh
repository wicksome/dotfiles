#!/bin/sh

echo Install all AppStore Apps at first!
# If you are looking into a solution to automate AppStore installs,
# check mas https://github.com/argon/mas
# I installed XCode, Simplenote, Clocks, Stuffit Expander, Cloudapp, Forklift.
read -p "Press any key to continue... " -n1 -s
echo  '\n'

# Install Homebrew

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

brew tap caskroom/cask
brew tap caskroom/versions

# Development
brew install jenv
brew install node
brew cask install caskroom/versions/java8

# Software
brew cask install --appdir="/Applications" appcleaner
brew cask install --appdir="/Applications" bartender
brew cask install --appdir="/Applications" bettertouchtool
brew cask install --appdir="/Applications" fantastical
brew cask install --appdir="/Applications" visual-studio-code
brew cask install --appdir="/Applications" dropbox
brew cask install --appdir="/Applications" hammerspoon
brew cask install --appdir="/Applications" vlc
# brew cask install --appdir="/Applications" 1password

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook suspicious-package