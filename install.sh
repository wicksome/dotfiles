#!/usr/bin/env bash

export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

confirm() {
    echo -e "$(tput bold)dotfiles root dir: $(tput setab 16)$(tput setaf 2) $DOTFILES_DIR $(tput sgr0)"
    read -r -p "Are you sure? [y/n] " response
    if [[ "$response" =~ ^(yes|y)$ ]]; then
        return 0 # true
    else
        return 1 # false 
    fi
}
confirm || exit 1

# Common functions

. "$DOTFILES_DIR/system/.function"

# Update dotfiles itself first

#if is-executable 

# Brunch of symlinks

alert() {
    local LINE='================================='
    printf "$(tput setaf 2)$(tput bold)%s %s %s$(tput sgr0)\n" "=============" $1 "${LINE:${#1}}"
}

alert "git"
ln -sfv "$DOTFILES_DIR/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/.gitignore_global" ~

# Package managers & packages


alert "brew" && . "$DOTFILES_DIR/install/brew.sh"
alert "bash" && . "$DOTFILES_DIR/install/bash.sh"
alert "vim" && . "$DOTFILES_DIR/install/vim.sh"

alert "other"
ln -sfv "$DOTFILES_DIR/.npmrc" ~
ln -sfv "$DOTFILES_DIR/.tmux.conf" ~

if [ "$(uname)" == "Darwin" ]; then
    alert "macos"
    . "$DOTFILES_DIR/install/brew-cask.sh"
    ln -sfv "$DOTFILES_DIR/.hammerspoon" ~
    ln -sfv "$DOTFILES_DIR/.mackup.cfg" ~
fi
