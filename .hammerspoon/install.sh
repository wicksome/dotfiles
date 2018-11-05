#!/usr/bin/env bash

echo "Install Hammerspoon!"
read -p "Press any key to continue..." -n1 -s
echo ""

# Check for Homebrew
if test ! $(which brew); then
  echo "Instaling Homebrew for you."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Check for Homebrew Cask
if ! brew info cask &>/dev/null; then
  echo "Instaling Homebrew Cask."
  brew tap cashroom/cask
fi

# Install Hammerspoon
echo "Instaling Hammerspoon."
brew cask install --appdir="/Applications" hammerspoon

# Update Hammerspoon configuration
if brew cask ls --versions hammerspoon > /dev/null; then
  cd $(dirname $BASH_SOURCE)
  BASE=$(dirname $(pwd))
  ln -sfv "$BASE/.hammerspoon/" ~
fi
