# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

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

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vcs dir)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs time)

######
# DIR
#####

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

#######
# VCS
########

POWERLEVEL9K_VCS_CLEAN_BACKGROUND='022'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='130'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='130'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='white'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='white'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='white'

POWERLEVEL9K_SHOW_CHANGESET='true'

POWERLEVEL9K_VCS_GIT_ICON=''
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=''
# POWERLEVEL9K_VCS_STAGED_ICON='\u00b1'
# POWERLEVEL9K_VCS_UNTRACKED_ICON='\u25CF' 
# POWERLEVEL9K_VCS_UNSTAGED_ICON='\u00b1'
# POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='\u2193'
# POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='\u2191'

POWERLEVEL9K_TIME_ICON=''
POWERLEVEL9K_TIME_BACKGROUND="008"
POWERLEVEL9K_TIME_FOREGROUND="white"
POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_COLOR=""

POWERLEVEL9K_STATUS_CROSS='true'
POWERLEVEL9K_STATUS_OK='false'

# online / offline status mode
ONLINE='%{%F{green}%}◉'
OFFLINE='%{%F{red}%}⦿'

ZSH_DISABLE_COMPFIX=true

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  iterm2
  zsh-syntax-highlighting
  zsh-autosuggestions
  autojump
  git-following
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias ll="ls -al"
alias gs="git status"
alias gd="git diff"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh


