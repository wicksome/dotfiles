#!/bin/bash

# 현재 환경설정 파일로 갱신하기

# file
f_bashrc=".bashrc"
f_bash_profile=".bash_profile"
f_gitconfig=".gitconfig"
f_vimrc=".vimrc"
f_atom_keymap="keymap.cson"

# target path
tp_bashrc="$HOME/$f_bashrc"
tp_bash_profile="$HOME/$f_bash_profile"
tp_gitconfig="$HOME/$f_gitconfig"
tp_vimrc="$HOME/$f_vimrc"
tp_atom_keymap="$HOME/.atom/$f_atom_keymap"

# source path
sp_bashrc="./$f_bashrc"
sp_bash_profile="./$f_bash_profile"
sp_gitconfig="./$f_gitconfig"
sp_vimrc="./$f_vimrc"
sp_atom_keymap="./$f_atom_keymap"

cp -v $tp_bashrc $sp_bashrc
cp -v $tp_bash_profile $sp_bash_profile
cp -v $tp_gitconfig $sp_gitconfig
cp -v $tp_vimrc $sp_vimrc
cp -v $tp_atom_keymap $sp_atom_keymap
