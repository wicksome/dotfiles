if ! is-executable brew; then
  echo "Skipping: Homebrew-Cask (not found: brew)"
  return
fi

brew tap caskroom/cask
brew tap caskroom/versions

# Install packages

apps=(
  caskroom/versions/java8
  appcleaner
  atom
  bartender
  bettertouchtool
  cheatsheet
  dash2
  dropbox
  duet
  evernote
  fantastical
  firefox
  fliqlo
  glimmerblocker
  google-chrome
  google-chrome-canary
  keycastr
  hammerspoon
  macdown
  popclip
  slack
  sublime-text
  vlc
  now
)

brew cask install "${apps[@]}"

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook suspicious-package

# Link Hammerspoon config
cd $(dirname $BASH_SOURCE)
BASE=$(dirname $(pwd))

[ -d ~/.hammerspoon ] || ln -sfv "$BASE/.hammerspoon/" ~

unset BASE
