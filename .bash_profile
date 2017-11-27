#!/bin/bash

source "$HOME/.bash_figlet"
. "$HOME/.bash_profile.private"
. "$HOME/.bash_profile.workspace"


# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# OS
if [ "$(uname -s)" = "Darwin" ]; then
  OS="macOS"
else
  OS=$(uname -s)
fi

# Resolve DOTFILES_DIR (assuming ~/.dotfiles on distros without readlink and/or $BASH_SOURCE/$0)
READLINK=$(which greadlink || which readlink)

SOURCE="${BASH_SOURCE[0]}"
CURRENT_SCRIPT=$($READLINK -f "$SOURCE")
export DOTFILES_DIR=$(dirname "$CURRENT_SCRIPT")

# Finally we can source the dotfiles (order matters)
for DOTFILE in "$DOTFILES_DIR"/system/.{function,function_*,path,env,alias,completion,grep,prompt,fzf}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

# Set LSCOLORS
#eval "$(dircolors "$DOTFILES_DIR"/system/.dir_colors)"
. "$DOTFILES_DIR"/system/.dir_colors

# Clean up
unset READLINK CURRENT_SCRIPT SCRIPT_PATH DOTFILE

# -----------------------------------------------------------------------------
# ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# autojump
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
 [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh


################################################################################
# Run app when open terminal
################################################################################

#$HOME/git/todo-cli/bin/todo


