#!/usr/bin/env bash

echo Install command-line tools using Homebrew.
read -p "Press any key to continue... " -n1 -s
echo ""

if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed

# Install VPN.
# brew install openconnect
# brew install gpg
# brew install pass

brew install wget
brew install fzf
brew install autojump   
brew install git
brew install git-lfs
brew install gist
brew install htop
brew install tree
brew install jq
brew install python-yq

# brew install plantuml
# brew install asciinema
# brew install asciidoctor
# brew install asciidoc
# brew install pandoc

# Check for Homebrew Cask
if ! brew info cask &>/dev/null; then
  echo "Instaling Homebrew Cask."
  brew tap cashroom/cask
fi

# Development
brew install jenv

# Applications
brew cask install --appdir="/Applications" appcleaner
brew cask install --appdir="/Applications" bartender
brew cask install --appdir="/Applications" bettertouchtool
brew cask install --appdir="/Applications" hammerspoon
brew cask install --appdir="/Applications" visual-studio-code
brew cask install --appdir="/Applications" vlc
brew cask install --appdir="/Applications" 1password

# Remove outdated versions from the cellar.
brew cleanup
