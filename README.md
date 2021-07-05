# .files

> These are my dotfiles. Take anything you want, but at your own risk.

## Installation

1. install [chrome](https://www.google.com/chrome/)
2. init [macos](https://github.com/wicksome/dotfiles/tree/master/macos) envir
3. install the [iterm](https://www.iterm2.com)
4. Run scripts of dotfiles
  ```bash
  cd
  mkdir workspace
  cd workspace
  git clone https://github.com/wicksome/dotfiles
  cd dotfiles
  ./install.sh
  ```
  ```bash
  cd install
  brew.sh
  zsh.sh
  vim.sh
  git.sh
  ...
  ```
  - `ln -slv $(pwd)/.aliased ~`
  
**Install Apps via brew script**

* Fantastical
  - Set 'Mini window keyboard shortcut': <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>alt</kbd>+<kbd>c</kbd>

**Install Apps via appstore**

* [1Password 7](https://itunes.apple.com/kr/app/1password-7-password-manager/id1333542190?l=en&mt=12)
* [MindNode 6](https://itunes.apple.com/kr/app/mindnode-6/id1289197285?l=en&mt=12)
* [Mate: Universal Tab Translator](https://itunes.apple.com/kr/app/mate-universal-tab-translator/id1005088137?l=en&mt=12)
  - Set Global shortcut: <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>cmd</kbd>+<kbd>d</kbd>


**Install Apps via web**

* [Docker for Mac](https://docs.docker.com/docker-for-mac/install/)
