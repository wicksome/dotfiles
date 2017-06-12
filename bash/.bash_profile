#!/bin/bash
# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

export LANGUAGE=ko_KR.UTF-8
export LANG="ko_KR.UTF-8"
export LC_ALL="ko_KR.UTF-8"

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

# -----------------------------------------------------------------------------
# Bash Exports
# -----------------------------------------------------------------------------

# vcprompt environment variables
export VCPROMPT_STAGED="⚙"
export VCPROMPT_MODIFIED="±"
export VCPROMPT_UNTRACKED="✘"

# some settings to be more colorful
export TERM=xterm-256color
# export TERM=xterm-color
export CLICOLOR=1
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export LSCOLORS=ExGxFxdxCxDxDxBxBxExEx
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:':'*.hwp=01;35'

################################################################################
# Import other configurations
################################################################################

source "$HOME/.bash_figlet"
. "$HOME/work/config/bash_work" # .(dot) == source

################################################################################
# PROMPT SETTING
# color reference:
#   http://misc.flogisoft.com/bash/tip_colors_and_formatting
# see:
#   http://linux.101hacks.com/ps1-examples/prompt-color-using-tput/
################################################################################

function prompt_custom_git {
    local c0=15      # font
    local c1=25      # branch
    local c2=236     # hash
    local c3=55      # gap
    local c4=5       # user
    local red=1      # git status

    local branch="$(tput setab $c1)$(tput setaf $c0)$(tput bold)  %b $(tput setaf $red)%m%u%a $(tput setab $c2)$(tput setaf $c1)$(tput sgr0)"
    # I unuse anything other than GIT.
	# local type="${b_cyan}${t_bold}${t_white} %s ${b_blue}${b_bold}${t_cyan}"
    local hash="$(tput setab $c2)$(tput setaf $c0) @%h $(tput sgr0)$(tput setab $c3)$(tput setaf $c2)$(tput sgr0)"
    local separator="$(tput setab $c4)$(tput setaf $c3)$(tput sgr0)"

	echo -e "$(VCPROMPT_FORMAT=${branch}${type}${hash}${separator} vcprompt)"
}

# show current status(user, dir path)
function prompt_custom_status {
    # style common
    local reset=$(tput sgr0) # same "${s}0${e}"
    local bold=$(tput bold)  # same "${s}1${e}"

    local s="\033["          # start
    local e="m"              # end

    local bg="48;5;"         # background
    local fg="38;5;"         # foreground

    # color code
    local white=15
    local purple=5
    local gray=238

    # background color
    local bg_purple="${s}${bg}${purple}${e}"
    local bg_gray="${s}${bg}${gray}${e}"

    # text color
    local fg_purple="${s}${fg}${purple}${e}"
    local fg_white="${s}${fg}${white}${e}"
    local fg_gray="${s}${fg}${gray}${e}"

    # customizing
    local user="${bg_purple}${fg_white}${bold} $USER 🌺  ${reset}$(tput setab 55)$(tput setaf $purple)$(tput setab $gray)$(tput setaf 55)"
    local path="${bg_gray}${fg_white} $(dirs -0) ${reset}${fg_gray}${reset}"

	echo -e "${user}${path}"
}

# 사용자 입력 받는 부분.
# color 설정하는 부분의 brackets을 prompt 길이 계산하는데 제외하기 위해서 분리.
# see:
#   https://askubuntu.com/a/24422/444925
#   http://mywiki.wooledge.org/BashFAQ/053
#   https://unix.stackexchange.com/questions/306773/prompt-line-is-deleted-by-switching-through-commands
function prompt_custom_command {
    local bg_gray=$(tput setab 238)
    local fg_gray=$(tput setaf 238)
    local reset=$(tput sgr0)

    printf '\001%s\002%s\001%s\002%s\001%s\002' "$bg_gray" " ⚡  " "$reset$fg_gray" " " "$reset"
}

export PS1='\n$(prompt_custom_git)$(prompt_custom_status)\n$(prompt_custom_command)'

# -----------------------------------------------------------------------------
# ALIASES
# -----------------------------------------------------------------------------

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

alias top_commands="history | awk '{print \$2}' | awk 'BEGIN{FS=\"|\"}{print \$1}' | sort | uniq -c | sort -n | tail -n 20 | sort -nr"

alias l="ls -l ${colorflag}"
alias ll="ls -la ${colorflag}"
alias lsd='ls -l ${colorflag} | grep "^d"'
alias ls="command ls ${colorflag}"

alias ..="cd .."
alias ...="cd ../../"

alias htop="sudo htop"
alias top='top -o cpu'
alias update-prompt="source ~/.bashrc"

alias gs='git status'
alias gl='git lg1'
alias gl2='git lg2'
alias gd='git diff'
# alias gm='git mg'
# alias gf='git fc'
# alias gb='git br'
# alias gc='git co'
# alias gcb='git co -b'
# alias gp='git push'
# alias gpf='git push -f'
# alias gbd='git br -D'
# alias gcm='git commit -m'
# alias gca='git commit --amend'
# alias gr='git rebase'
# alias gri='git rebase -i'
# alias grh='git reset --hard'
# alias gff='git flow feature'

# Open Application
alias st='open -a "Sublime Text"'
alias atom='open -a Atom'
alias typo='open -a Typora'
alias md='open -a MacDown'
alias hosts='grep '^[0-9]' /etc/hosts'
alias ahd='sudo /Users/yeongjun/git/ahd/bin/ahd'
alias td='$HOME/go/bin/td'

alias chm-ajax='open /Applications/Google\ Chrome.app/ -n --args --allow-file-access-from-files'

alias ip='ifconfig en4 | awk "{ print $2}" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"'
alias stime='last reboot | head -2'


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

