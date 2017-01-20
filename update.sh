#!/bin/bash

# bash
base_rc="$HOME/.bashrc"
base_profile="$HOME/.bash_profile"
base_figlet="$HOME/.bash_figlet"
cp -v $base_rc ./bash/
cp -v $base_profile ./bash/
cp -v $base_figlet ./bash/

# vim
vim_rc="$HOME/.vimrc"
cp -v $vim_rc ./vim/

# git
git_config="$HOME/.gitconfig"
cp -v $git_config ./git/

# atom
atom_config="$HOME/.atom/config.cson"
atom_keymap="$HOME/.atom/keymap.cson"
atom_init="$HOME/.atom/init.coffee"
cp -v $atom_config ./atom/
cp -v $atom_keymap ./atom/
cp -v $atom_init ./atom/

# intellij



# git commit

git add -A
git commit -m "updated. `date`"

