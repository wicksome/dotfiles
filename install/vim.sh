#!/bin/bash

if [ -z "$DOTFILES_DIR" ]; then
    echo -e "$(tput setaf 1)$(tput bold)DOTFILES_DIR doesn't exist.$(tput sgr0)" && exit 1
fi

export GIT_SSL_NO_VERIFY=true
mkdir -p ~/.vim/autoload
curl --insecure -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim

# vimrc
ln -sf $DOTFILES_DIR/.vimrc ~/.vimrc
vim +PlugInstall +qall

# install completers
~/.vim/plugged/youcompleteme/install.py --tern-completer
#~/.vim/plugged/youcompleteme/install.py --gocode-completer
