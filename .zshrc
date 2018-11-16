# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.npm-global/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/yeongjun/.oh-my-zsh"
ZSH_THEME="powerlevel9k/powerlevel9k"

export TERM=xterm-256color
# export LSCOLORS=cxagfxdxbxxxxxxxxxxxxx
export LS_COLORS='di=32:ln=36:so=35:pi=33:ex=31:bd=0:cd=0:su=31;47:sg=31;47:tw=32;47:ow=32;47'

DISABLE_AUTO_TITLE="true"

# Configuracion POWERLVEL9K
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status vcs dir newline vi_mode_joined)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
POWERLEVEL9K_DISABLE_RPROMPT=true

########################################################################
# DIR
########################################################################

POWERLEVEL9K_DIR_HOME_BACKGROUND='236'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='236'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='236'
POWERLEVEL9K_DIR_HOME_FOREGROUND='white'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='white'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='white'

# Disable dir/git icons
POWERLEVEL9K_HOME_ICON=''
POWERLEVEL9K_HOME_SUB_ICON=''
POWERLEVEL9K_FOLDER_ICON=''

########################################################################
# VCS
########################################################################

POWERLEVEL9K_VCS_CLEAN_BACKGROUND='022'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='130'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='130'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='white'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='white'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='white'

POWERLEVEL9K_SHOW_CHANGESET='true'

POWERLEVEL9K_VCS_GIT_ICON=''
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=''

POWERLEVEL9K_TIME_ICON=''
POWERLEVEL9K_TIME_BACKGROUND="008"
POWERLEVEL9K_TIME_FOREGROUND="white"
POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_COLOR=""

POWERLEVEL9K_STATUS_CROSS='true'
POWERLEVEL9K_STATUS_OK='false'

POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND='239'
POWERLEVEL9K_VI_MODE_INSERT_BACKGROUND='239'
POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND='black'
POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND='226'
POWERLEVEL9K_VI_INSERT_MODE_STRING=" ⚡"
POWERLEVEL9K_VI_COMMAND_MODE_STRING=" ⚡"

ZSH_DISABLE_COMPFIX=true
CASE_SENSITIVE="true"
HISTSIZE=1000
SAVEHIST=1000

plugins=(
  vi-mode
  git
  iterm2
  zsh-completions
  zsh-syntax-highlighting
  autojump
  fzf
  node
  npm
)

source $ZSH/oh-my-zsh.sh

# for vi-mode
function zle-keymap-select zle-line-init
{
    # change cursor shape in iTerm2
    case $KEYMAP in
        vicmd)      print -n -- "\E]50;CursorShape=0\C-G";;  # block cursor
        viins|main) print -n -- "\E]50;CursorShape=1\C-G";;  # line cursor
    esac

    zle reset-prompt
    zle -R
}

function zle-line-finish
{
    print -n -- "\E]50;CursorShape=0\C-G"  # block cursor
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# Preferred editor for local and remote sessions
#if [[ -n $SSH_CONNECTION ]]; then
#  export EDITOR='vim'
#else
#  export EDITOR='mvim'
#fi


########################################################################
# sources
########################################################################

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

[[ -f "$HOME/workspace/dotfiles-work/.bash_profile" ]] && source "$HOME/workspace/dotfiles-work/.bash_profile"
