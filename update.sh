#!/bin/bash

# 현재 환경설정 파일로 갱신하기
FILE_BASHRC="$HOME/.bashrc"
FILE_BASH_PROFILE="$HOME/.bash_profile"
FILE_GITCONFIG="$HOME/.gitconfig"
FILE_VIMRC="$HOME/.vimrc"

cp -v $FILE_BASHRC ./.bashrc
cp -v $FILE_BASH_PROFILE ./.bash_profile
cp -v $FILE_GITCONFIG ./.gitconfig
cp -v $FILE_VIMRC ./.vimrc
