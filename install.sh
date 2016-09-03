#!/bin/bash

# variablea--------------------------------
# file
f_bashrc=".bashrc"
f_bash_profile=".bash_profile"
f_gitconfig=".gitconfig"
f_vimrc=".vimrc"
f_atom_keymap="keymap.cson"

# source path
s_bashrc="./$f_bashrc"
s_bash_profile="./$f_bash_profile"
s_gitconfig="./$f_gitconfig"
s_vimrc="./$f_vimrc"
s_atom_keymap="./$f_atom_keymap"

# destination path
d_bashrc="$HOME/$f_bashrc"
d_bash_profile="$HOME/$f_bash_profile"
d_gitconfig="$HOME/$f_gitconfig"
d_vimrc="$HOME/$f_vimrc"
d_atom_keymap="$HOME/.atom/$_atom_keymap"

# etc
dir_backup_base="$HOME/.myenv"
dir_backup="$dir_backup_base/$(date +'%Y%m%d-%H%M%S')"

# logic ----------------------------------
# create base backup directory
if [ ! -d "$dir_backup_base" ]; then
	echo "[INFO] CREATE .myenv"
	mkdir -v $dir_backup_base
fi

# backup current env file
echo "[INFO] BACKUP ENV: $dir_backup"
mkdir -v $dir_backup
cp -v $d_bashrc			$dir_backup/$f_bashrc
cp -v $d_bash_profile	$dir_backup/$f_bash_profile
cp -v $d_gitconfig		$dir_backup/$f_gitconfig
cp -v $d_vimrc			$dir_backup/$f_vimrc
cp -v $d_atom_keymap	$dir_backup/$f_atom_keymap

# copy to local
echo "[INFO] copy to local"
cp -v $s_bashrc			$HOME/
cp -v $s_bash_profile	$HOME/
cp -v $s_gitconfig		$HOME/
cp -v $s_vimrc			$HOME/
cp -v $s_atom_keymap	$HOME/

echo "[INFO] apply bash"
source ~/.bash_profile
