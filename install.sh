#!/usr/bin/env bash

clear

export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

########################################
# Check directory path of the dotfiles.
########################################
echo -e "📦 DOTFILES_DIR: $(tput bold)$DOTFILES_DIR$(tput sgr0)"
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
alert "brew" && . "$DOTFILES_DIR/install/brew.sh"

echo "$(tput setaf 0)$(tput bold)--------------------------------------------------$(tput sgr0)"
alert "zsh" && . "$DOTFILES_DIR/install/zsh.sh"

echo "$(tput setaf 0)$(tput bold)--------------------------------------------------$(tput sgr0)"
alert "vim" && . "$DOTFILES_DIR/install/vim.sh"

alert "other"
# ln -sfv "$DOTFILES_DIR/.npmrc" ~

if [ "$(uname)" == "Darwin" ]; then
    alert "macos"
    ln -sfv "$DOTFILES_DIR/.hammerspoon" ~
    # ln -sfv "$DOTFILES_DIR/.mackup.cfg" ~
fi

unset DOTFILES_DIR
