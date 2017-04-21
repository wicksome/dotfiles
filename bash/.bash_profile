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

# -----------------------------------------------------------------------------
# IMPORTS OTHER CONFIG
# -----------------------------------------------------------------------------
source "$HOME/.bash_figlet"
source "$HOME/work/config/bash_work"

# -----------------------------------------------------------------------------
# PROMPT
# -----------------------------------------------------------------------------

function DISPLAY_GIT_REPOSITORY {
	## color setting
	local c_clean="\033[0m"
	local c_reverse="\033[07m"
	local b_block="\033[40"
	local b_red="\033[41"
	local b_green="\033[42"
	local b_yello="\033[43"
	local b_blue="\033[44"
	local b_magenta="\033[45"
	local b_cyan="\033[46"
	local b_white="\033[47"
	local t_base="\033["
	local t_block=";30m"
	local t_red=";31m"
	local t_green=";32m"
	local t_yello=";33m"
	local t_blue=";34m"
	local t_magenta=";35m"
	local t_cyan=";36m"
	local t_white=";37m"
	local t_bold=";1"

	local brach_icon=""
	local separator=""

	local GIT_BRANCH="${b_green}${b_bold}${t_block} ${brach_icon} %b ${b_green}${b_bold}${t_red}%m%u%a ${b_cyan}${t_bold}${t_green}${separator}"
	local GIT_TYPE="${b_cyan}${t_bold}${t_white} %s ${b_blue}${b_bold}${t_cyan}${separator}"
	local GIT_HASH="${b_blue}${b_bold}${t_white} @%h ${c_clean}${t_base}${b_bold}${t_blue}${separator}"
	local GIT_SEPARATOR="${c_clean}${t_base}${t_bold}${t_magenta}${c_reverse}${separator}${c_clean}"

	echo -e "$(VCPROMPT_FORMAT=${GIT_BRANCH}${GIT_TYPE}${GIT_HASH}${GIT_SEPARATOR} vcprompt)"
}

function ptompt_user {
	local separator=""

	local user="\033[45;1;37m $USER \033[41;1;35m${separator}" # \u
	local host="\033[41;1;37m $(hostname|awk -v FS='.' '{print $1}') \033[43;1;31m${separator}" # \h

	# customizing...
	# local user="\033[48;5;098;37m $USER \033[41;38;5;098m${separator}" # \u
	# local host="\033[48;5;105;37m $(hostname|awk -v FS='.' '{print $1}') \033[41;38;5;105m${separator}" # \h

	echo -e "${user}${host}"
}

export PS1='\n$(DISPLAY_GIT_REPOSITORY)$(ptompt_user) \w \[\033[0m\[\033[1;33m\]\033[0m \n\[\033[40;1;33m\] ⚡ \[\033[0m\]\[\033[1;30m\]\[\033[0m\] '
# export PS1='\n$(DISPLAY_GIT_REPOSITORY)\[\033[45;1;37m\] \u \[\033[41;1;35m\]\[\033[41;1;37m\] \h \[\033[43;1;31m\]\[\033[43;1;30m\] \w \[\033[0m\[\033[1;33m\]\033[0m \n\[\033[40;1;33m\] ⚡ \[\033[0m\]\[\033[1;30m\]\[\033[0m\] '

# custom prompt example
function DISPLAY_PROMPT {
	local p="\033[01;38;5;52m"
    local l="\033[01;38;5;124m"
    local a="\033[01;38;5;196m"
    local s="\033[01;38;5;202m"
    local m="\033[01;38;5;208m"
    local a2="\033[01;38;5;214m"
    local r="\033[01;38;5;220m"
    local o="\033[01;38;5;226m"
    local b="\033[01;38;5;228m"

	echo -e "${p} \u ${l}l${a}a${s}s${m}m${a2}a${r}r${o}o${b}b"
}

function colorgrid( ) {
    iter=16
    while [ $iter -lt 52 ]
    do
        second=$[$iter+36]
        third=$[$second+36]
        four=$[$third+36]
        five=$[$four+36]
        six=$[$five+36]
        seven=$[$six+36]
        if [ $seven -gt 250 ];then seven=$[$seven-251]; fi

        echo -en "\033[38;5;$(echo $iter)m█ "
        printf "%03d" $iter
        echo -en "   \033[38;5;$(echo $second)m█ "
        printf "%03d" $second
        echo -en "   \033[38;5;$(echo $third)m█ "
        printf "%03d" $third
        echo -en "   \033[38;5;$(echo $four)m█ "
        printf "%03d" $four
        echo -en "   \033[38;5;$(echo $five)m█ "
        printf "%03d" $five
        echo -en "   \033[38;5;$(echo $six)m█ "
        printf "%03d" $six
        echo -en "   \033[38;5;$(echo $seven)m█ "
        printf "%03d" $seven

        iter=$[$iter+1]
        printf '\r\n'
    done
}

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

alias st='open -a "Sublime Text"'
alias typo='open -a Typora'
alias md='open -a MacDown'
alias hosts='grep '^[0-9]' /etc/hosts'
alias ahd='sudo /Users/yeongjun/git/ahd/bin/ahd'

alias chm-ajax='open /Applications/Google\ Chrome.app/ -n --args --allow-file-access-from-files'

alias ip='ifconfig en4 | awk "{ print $2}" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"'
alias stime='last reboot | head -2'


# -----------------------------------------------------------------------------
# ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
 [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
