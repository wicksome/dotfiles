#!/bin/bash

if [ -z "$DOTFILES_DIR" ]; then
    echo -e "$(tput setaf 1)$(tput bold)DOTFILES_DIR doesn't exist.$(tput sgr0)" && exit 1
fi

brew install bash

grep "/usr/local/bin/bash" /private/etc/shells &>/dev/null || sudo bash -c "echo /usr/local/bin/bash >> /private/etc/shells"
chsh -s /usr/local/bin/bash

ln -sfv "$DOTFILES_DIR/.bashrc" ~
ln -sfv "$DOTFILES_DIR/.bash_profile" ~
