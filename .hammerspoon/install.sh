#!/usr/bin/env bash

echo "Install Hammerspoon!"
read -p "Press any key to continue..." -n1 -s
echo ""

if test ! $(which brew); then
  echo "Instaling Homebrew for you."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! brew info cask &>/dev/null; then
  echo "Instaling Homebrew Cask."
  brew tap cashroom/cask
fi

echo "Instaling Hammerspoon."
brew cask install --appdir="/Applications" hammerspoon

#
if brew cask ls --versions hammerspoon > /dev/null; then
  cd $(dirname $BASH_SOURCE)
  BASE=$(dirname $(pwd))
  ln -sfv "$BASE/.hammerspoon/" ~
fi

