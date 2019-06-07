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

# brew cask install --appdir="/Applications" duet
# brew cask install --appdir="/Applications" cheatsheet
# brew cask install --appdir="/Applications" dash2
# brew cask install --appdir="/Applications" fliqlo

# 앱 스토어
echo "copied"
# brew cask install --appdir="/Applications" mindnode # 따로 받아야 최신버전 받

# 각 사이트에서 다운로드 받아야 하는 애플리케이션
echo "intellij IDEA"
echo "postman"

echo "yubisitch - https://github.com/pallotron/yubiswitch"
echo "ybk-store"
