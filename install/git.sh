#!/usr/bin/env bash

if [ -z "$DOTFILES_DIR" ]; then
    echo -e "$(tput setaf 1)$(tput bold)DOTFILES_DIR doesn't exist.$(tput sgr0)" && exit 1
fi

read -r -p "❓ Do you wanna install $(tput bold)git$(tput sgr0)? [y/n] " res
if [[ "$res" =~ ^(yes|y)$ ]]; then
  ln -sfv "$DOTFILES_DIR/git/.gitconfig" ~
  ln -sfv "$DOTFILES_DIR/git/.gitignore_global" ~
fi
