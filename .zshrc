# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.npm-global/bin:$PATH

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

export TERM="xterm-256color"
export LS_COLORS='di=32:ln=36:so=35:pi=33:ex=31:bd=0:cd=0:su=31;47:sg=31;47:tw=32;47:ow=32;47'

########################################################################
# zsh configurations
########################################################################

export ZSH="/Users/yeongjun/.oh-my-zsh"
ZSH_THEME="powerlevel9k/powerlevel9k"

ZSH_DISABLE_COMPFIX=true

DISABLE_AUTO_TITLE="true"
CASE_SENSITIVE="true"
HISTSIZE=1000
SAVEHIST=1000

# Preferred editor for local and remote sessions
#if [[ -n $SSH_CONNECTION ]]; then
#  export EDITOR='vim'
#else
#  export EDITOR='mvim'
#fi

plugins=(
  vi-mode
  git
  iterm2
  zsh-completions
  zsh-syntax-highlighting
  zsh-autosuggestions
  autojump
  fzf
  node
  npm
  docker
)

########################################################################
# Powerlevel9k theme
########################################################################

P9K_MODE='nerdfont-complete'
P9K_PROMPT_ADD_NEWLINE=true
P9K_LEFT_PROMPT_ELEMENTS=(status vcs dir newline vi_mode_joined)
P9K_DISABLE_RPROMPT=true

# DIR

P9K_DIR_HOME_ICON=''
P9K_DIR_HOME_BACKGROUND='236'
P9K_DIR_HOME_FOREGROUND='white'
P9K_DIR_HOME_SUBFOLDER_ICON=''
P9K_DIR_HOME_SUBFOLDER_BACKGROUND='236'
P9K_DIR_HOME_SUBFOLDER_FOREGROUND='white'
P9K_DIR_DEFAULT_ICON=''
P9K_DIR_DEFAULT_BACKGROUND='236'
P9K_DIR_DEFAULT_FOREGROUND='white'

# VCS

P9K_VCS_GIT_ICON=''
P9K_VCS_GIT_GITHUB_ICON=''
P9K_VCS_CLEAN_BACKGROUND='022'
P9K_VCS_UNTRACKED_BACKGROUND='130'
P9K_VCS_MODIFIED_BACKGROUND='130'
P9K_VCS_CLEAN_FOREGROUND='white'
P9K_VCS_UNTRACKED_FOREGROUND='white'
P9K_VCS_MODIFIED_FOREGROUND='white'
P9K_VCS_SHOW_CHANGESET='true'

P9K_STATUS_OK='false'
P9K_STATUS_CROSS='true'

P9K_VI_MODE_INSERT_STRING='\ue62b'
P9K_VI_MODE_INSERT_BACKGROUND='239'
P9K_VI_MODE_INSERT_FOREGROUND='226'
P9K_VI_MODE_NORMAL_STRING='\ue62b'
P9K_VI_MODE_NORMAL_BACKGROUND='239'
P9K_VI_MODE_NORMAL_FOREGROUND='black'

# ETC(plugins)

ZLE_RPROMPT_INDENT=0
P9K_CURSOR_SHAPE="true"
P9K_CURSOR_NOBLINK="true"

# for vi-mode
function zle-keymap-select zle-line-init {
  # change cursor shape in iTerm2
  case $KEYMAP in
    vicmd)      print -n -- "\E]50;CursorShape=0\C-G";;  # block cursor
    viins|main) print -n -- "\E]50;CursorShape=1\C-G";;  # line cursor
  esac

  zle reset-prompt
  zle -R
}

function zle-line-finish {
  print -n -- "\E]50;CursorShape=0\C-G"  # block cursor
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

source $ZSH/oh-my-zsh.sh


########################################################################
# sources
########################################################################

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

[[ -f "$HOME/workspace/dotfiles-work/.bash_profile" ]] && source "$HOME/workspace/dotfiles-work/.bash_profile"
