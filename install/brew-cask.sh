if ! is-executable brew; then
  echo "Skipping: Homebrew-Cask (not found: brew)"
  return
fi

brew tap caskroom/cask
brew tap caskroom/versions

# Install packages
brew cask install caskroom/versions/java8
brew cask install appcleaner
brew cask install atom
brew cask install bartender
brew cask install bettertouchtool
brew cask install cheatsheet
brew cask install dash2
brew cask install dropbox
brew cask install duet
brew cask install evernote
brew cask install fantastical
brew cask install firefox
brew cask install fliqlo
brew cask install glimmerblocker
brew cask install google-chrome
brew cask install google-chrome-canary
brew cask install keycastr
brew cask install hammerspoon
brew cask install macdown
brew cask install popclip
brew cask install slack
brew cask install sublime-text
brew cask install vlc
brew cask install now

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook suspicious-package

# Link Hammerspoon config
cd $(dirname $BASH_SOURCE)
BASE=$(dirname $(pwd))

[ -d ~/.hammerspoon ] || ln -sfv "$BASE/.hammerspoon/" ~

unset BASE
