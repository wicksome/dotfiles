#!/bin/bash
# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

# path ---------------------------------------------------
export M2_HOME=/Users/yeongjun/apps/apache-maven-3.3.9
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

export JAVA_6=/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
export JAVA_7=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home
export JAVA_8=/Library/Java/JavaVirtualMachines/jdk1.8.0_73.jdk/Contents/Home
export JAVA_HOME=$JAVA_8
export PATH=$JAVA_HOME/bin:$PATH

# homebrews should always take precedence
export PATH=/usr/local/bin:$PATH

# todo
export TODO_DB_PATH=$HOME/Dropbox/todo.json

################################################################################

source "$HOME/.bash_figlet"
. "$HOME/work/config/bash_work" # .(dot) == source


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
for DOTFILE in "$DOTFILES_DIR"/system/.{function,path,env,alias,grep,prompt}; do
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

td

