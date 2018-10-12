#!/usr/bin/env bash
echo Install Hammerspoon!
read -p "Press any key to continue..." -n1 -s
echo '\n'

if test ! $(which brew)
then
  echo "Instaling Homebrew for you."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew tap cashroom/cask
brew cask install --appdir="/Applications" hammerspoon


cd $(dirname $BASH_SOURCE)
BASE=$(dirname $(pwd))
[ -d ~/.hammerspoon ] || ln -sfv "$BASE/.hammerspoon/" ~
