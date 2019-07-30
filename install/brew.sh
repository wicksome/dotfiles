#!/usr/bin/env bash

echo Install command-line tools using Homebrew.
read -p "Press any key to continue... " -n1 -s
echo ""

if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
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

# mac backup
# brew install mackup

# Install VPN.
brew install openconnect
brew install gpg
brew install pass

# Install other useful binaries.
# brew install tmux
# brew install tmuxinator-completion
brew install wget
brew install the_silver_searcher # https://github.com/ggreer/the_silver_searcher
brew install fzf
brew install autojump   
brew install git
brew install git-flow
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

# Remove outdated versions from the cellar.
brew cleanup
