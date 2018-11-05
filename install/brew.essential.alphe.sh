#!/bin/sh

echo Install all AppStore Apps at first!
read -p "Press any key to continue... " -n1 -s
echo ""

# Install Homebrew

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

brew tap caskroom/cask
brew tap caskroom/versions

brew cask install --appdir="/Applications" duet
# brew cask install --appdir="/Applications" cheatsheet
# brew cask install --appdir="/Applications" dash2
# brew cask install --appdir="/Applications" fliqlo

# App Store
echo "copied"
# brew cask install --appdir="/Applications" copied
# brew cask install --appdir="/Applications" mindnode # 따로 받아야 최신버전 받

echo "yubisitch(for works) - https://github.com/pallotron/yubiswitch"

echo "intellij IDEA"
echo "sourcetree"
echo "ybk-store"
