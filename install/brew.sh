#!/usr/bin/env bash

echo Install command-line tools uring Homebrew.
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
brew install gnu-sed --with-default-names

# mac backup
# brew install mackup

# Install `wget` with IRI support.
brew install wget --with-iri

# Install VPN.
brew install openconnect
brew install gpg
brew install pass

# Install applications for develop.

#brew install go
#brew install gradle
#brew install elasticsearch

# Install other useful binaries.
# brew install tmux
# brew install tmuxinator-completion
brew install the_silver_searcher
brew install fzf
brew install autojump   
brew install git
brew install git-flow
brew install git-lfs
brew install gist
#brew install tig
brew install htop
#brew install httpie
#brew install mas
#brew install rename
brew install tree
# brew install plantuml
brew install jq
# brew install asciinema

# Install apps for documentation.
# brew install asciidoctor
# brew install asciidoc
# brew install pandoc

# Install Mac applications.
which cask || brew tap caskroom/cask

# Remove outdated versions from the cellar.
brew cleanup
