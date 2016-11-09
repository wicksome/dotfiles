#!/bin/bash

# bash
base_rc="$HOME/.bashrc"
base_profile="$HOME/.bash_profile"
cp -v $base_rc ./bash/
cp -v $base_profile ./bash/

# vim
vim_rc="$HOME/.vimrc"
cp -v $vim_rc ./vim/

# git
git_config="$HOME/gitconfig"
cp -v $git_config ./git/

# atom
atom_config="$HOME/.atom/config.cson"
atom_keymap="$HOME/.atom/keymap.cson"
atom_init="$HOMT/init.coffee"
cp -v $atom_config ./atom/
cp -v $atom_keymap ./atom/
cp -v $atom_init ./atom/

# intellij
