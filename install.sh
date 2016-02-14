#!/bin/bash

# variablea--------------------------------
# file
f_bashrc=".bashrc"
f_bash_profile=".bash_profile"
f_gitconfig=".gitconfig"
f_vimrc=".vimrc"

# source path
s_bashrc="./$f_bashrc"
s_bash_profile="./$f_bash_profile"
s_gitconfig="./$f_gitconfig"
s_vimrc="./$f_vimrc"

# destination path
d_bashrc="$HOME/$f_bashrc"
d_bash_profile="$HOME/$f_bash_profile"
d_gitconfig="$HOME/$f_gitconfig"
d_vimrc="$HOME/$f_vimrc"

# etc
dir_backup_base="$HOME/.myenv"
dir_backup="$dir_backup_base/$(date +'%Y%m%d-%H%M%S')"

# logic ----------------------------------
# create base backup directory
if [ ! -d "$dir_backup_base" ]; then
	echo "[INFO] CREATE .myenv"
	mkdir $dir_backup_base
fi

# backup current env file
echo "[INFO] CREATE DIR FOR ENV BACKUP: $dir_backup"
mkdir $dir_backup
cp $d_bashrc		$dir_backup/$f_bashrc
cp $d_bash_profile	$dir_backup/$f_bash_profile
cp $d_gitconfig		$dir_backup/$f_gitconfig
cp $d_vimrc			$dir_backup/$f_vimrc

# copy to local
cp $s_bashrc		$d_bashrc
cp $s_bash_profile	$d_bash_profile
cp $s_gitconfig		$d_gitconfig
cp $s_vimrc			$d_vimrc

source ~/.bash_profile
