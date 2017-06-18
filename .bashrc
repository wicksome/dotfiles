#!/bin/bash

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

[ -n "$PS1" ] && source ~/.bash_profile;

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
if [ -f $(brew --prefix)/etc/bash_completion ]; then source $(brew --prefix)/etc/bash_completion; fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

echo "bashrc"
# why dont run?
