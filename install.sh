#!/usr/bin/env bash

clear

export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

########################################
# Check directory path of the dotfiles.
########################################
echo -e "📦 Base Directory Path: $(tput bold)$DOTFILES_DIR$(tput sgr0)"
# echo -e "📦 $(tput bold)dotfiles root dir: $(tput setab 16)$(tput setaf 2) $DOTFILES_DIR $(tput sgr0)"
read -r -p "❓ Are you sure? [y/n] " response
if ! [[ "$response" =~ ^(yes|y)$ ]]; then
  exit 1 
fi

####################
# Import functions
####################

. "$DOTFILES_DIR/system/.function"
. "$DOTFILES_DIR/install/utils.sh"

alert() {
    local LINE='================================='
    printf "$(tput setaf 2)$(tput bold)%s %s %s$(tput sgr0)\n" "=============" $1 "${LINE:${#1}}"
}

#############################
# git
###########################

newline
$DOTFILES_DIR/install/git.sh

# Package managers & packages

echo "$(tput setaf 0)$(tput bold)--------------------------------------------------$(tput sgr0)"
# alert "brew" && . "$DOTFILES_DIR/install/brew.sh"

echo "$(tput setaf 0)$(tput bold)--------------------------------------------------$(tput sgr0)"
# alert "bash" && . "$DOTFILES_DIR/install/bash.sh"

echo "$(tput setaf 0)$(tput bold)--------------------------------------------------$(tput sgr0)"
# alert "vim" && . "$DOTFILES_DIR/install/vim.sh"

alert "other"
# ln -sfv "$DOTFILES_DIR/.npmrc" ~
# ln -sfv "$DOTFILES_DIR/.tmux.conf" ~

if [ "$(uname)" == "Darwin" ]; then
    alert "macos"
    # . "$DOTFILES_DIR/install/brew-cask.sh"
    # ln -sfv "$DOTFILES_DIR/.hammerspoon" ~
    # ln -sfv "$DOTFILES_DIR/.mackup.cfg" ~
fi

