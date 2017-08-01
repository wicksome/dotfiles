#!/usr/bin/env bash

# Install command-line tools using Homebrew.

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
# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`. To do so, run `sudo chsh -s /usr/local/bin/bash`.
brew install bash
brew tap homebrew/versions
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

# Install `wget` with IRI support.
brew install wget --with-iri

# Install VIM of macOS tools.
brew install macvim --with-override-system-vi

# Install VPN.
brew install openconnect
brew install gpg
brew install pass

# Install applications for develop.
brew install node
brew install go
brew install gradle
brew install elasticsearch

# Install other useful binaries.
brew install the_silver_searcher
brew install fzf
brew install autojump   
brew install git
brew install git-flow
brew install git-lfs
brew install htop
brew install httpie
brew install mas
brew install rename
brew install tmuxinator-completion
brew install tree

# Install Mac applications.
which cask || brew tap caskroom/cask

# Remove outdated versions from the cellar.
brew cleanup
