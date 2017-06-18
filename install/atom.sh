#!/bin/bash

if [ -z "$DOTFILES_DIR" ]; then
    echo -e "$(tput setaf 1)$(tput bold)DOTFILES_DIR doesn't exist.$(tput sgr0)" && exit 1
fi

mkdir -p ~/.atom

ln -sfv "$DOTFILES_DIR/.atom/config.cson" ~/.atom
ln -sfv "$DOTFILES_DIR/.atom/init.coffee" ~/.atom
ln -sfv "$DOTFILES_DIR/.atom/keymap.cson" ~/.atom
ln -sfv "$DOTFILES_DIR/.atom/snippets.cson" ~/.atom
ln -sfv "$DOTFILES_DIR/.atom/styles.less" ~/.atom
