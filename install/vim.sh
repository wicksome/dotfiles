#!/bin/bash

if [ -z "$DOTFILES_DIR" ]; then
    echo -e "$(tput setaf 1)$(tput bold)DOTFILES_DIR doesn't exist.$(tput sgr0)" && exit 1
fi

echo Install macvim uring Homebrew.
read -p "Press any key to continue... " -n1 -s
echo ""

if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

# Install VIM of macOS tools.
brew install macvim --with-override-system-vi

export GIT_SSL_NO_VERIFY=true
mkdir -p ~/.vim/autoload
curl --insecure -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim

# vimrc
ln -sf $DOTFILES_DIR/.vimrc ~/.vimrc
vim +PlugInstall +qall

# install completers
~/.vim/plugged/youcompleteme/install.py --tern-completer
#~/.vim/plugged/youcompleteme/install.py --gocode-completer
