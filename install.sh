

FILE_BASHRC="~/.bashrc"
FILE_BASH_PROFILE="~/.bash_profile"
FILE_GITCONFIG="~/.gitconfig"
FILE_VIMRC="~/.vimrc"



cp -v ./.bashrc $FILE_BASHRC
cp -v ./.bash_profile ~/.bash_profile
cp -v ./.gitconfig ~/.gitconfig
cp -v ./.vimrc ~/.vimrc
source ~/.bash_profile
