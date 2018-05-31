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
brew cask install caskroom/versions/java8

# Software
brew cask install --appdir="/Applications" appcleaner
brew cask install --appdir="/Applications" atom
brew cask install --appdir="/Applications" bartender
brew cask install --appdir="/Applications" bettertouchtool
brew cask install --appdir="/Applications" cheatsheet
brew cask install --appdir="/Applications" dash2
brew cask install --appdir="/Applications" dropbox
brew cask install --appdir="/Applications" duet
brew cask install --appdir="/Applications" evernote
brew cask install --appdir="/Applications" fantastical
brew cask install --appdir="/Applications" firefox
brew cask install --appdir="/Applications" fliqlo
brew cask install --appdir="/Applications" glimmerblocker
brew cask install --appdir="/Applications" google-chrome
# brew cask install --appdir="/Applications" google-chrome-canary
brew cask install --appdir="/Applications" keycastr
brew cask install --appdir="/Applications" hammerspoon
# brew cask install --appdir="/Applications" macdown
# brew cask install --appdir="/Applications" popclip
brew cask install --appdir="/Applications" slack
# brew cask install --appdir="/Applications" sublime-text
brew cask install --appdir="/Applications" vlc
# brew cask install --appdir="/Applications" now
# brew cask install --appdir="/Applications" 1password

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook suspicious-package

# Link Hammerspoon config
cd $(dirname $BASH_SOURCE)
BASE=$(dirname $(pwd))

[ -d ~/.hammerspoon ] || ln -sfv "$BASE/.hammerspoon/" ~

unset BASE
