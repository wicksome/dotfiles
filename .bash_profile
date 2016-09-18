####### .bash_profile

###### General
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

# prompt -------------------------------------------------

## color setting
c_clean="\033[0m"
c_reverse="\033[07m"
b_block="\033[40"
b_red="\033[41"
b_green="\033[42"
b_yello="\033[43"
b_blue="\033[44"
b_magenta="\033[45"
b_cyan="\033[46"
b_white="\033[47"
t_base="\033["
t_block=";30m"
t_red=";31m"
t_green=";32m"
t_yello=";33m"
t_blue=";34m"
t_magenta=";35m"
t_cyan=";36m"
t_white=";37m"
t_bold=";1"

c_branch=""
c_separator=""

DVCS_BRANCH="${b_green}${b_bold}${t_block} ${c_branch} %b ${b_green}${b_bold}${t_red}%m%u%a "
DVCS_TYPE="${b_cyan}${t_bold}${t_green}${c_separator}${b_cyan}${t_bold}${t_white} %s " 
DVCS_HASH="${b_blue}${b_bold}${t_cyan}${c_separator}${b_blue}${b_bold}${t_white} @%h "
DVCS_SEPARATOR="${c_clean}${t_base}${b_bold}${t_blue}${c_separator}${c_clean}${t_base}${t_bold}${t_magenta}${c_reverse}${c_clean}"

show_repository () {
	echo -e "$(VCPROMPT_FORMAT=${DVCS_BRANCH}${DVCS_TYPE}${DVCS_HASH}${DVCS_SEPARATOR} vcprompt)"
}

# \[ : begin
# \e[ : ASCII escape character(033) - prompt start
# 
# \] : end
FONT_WHITE=";37m"
COLOR1="\[\e[45;1;37m\]"
COLOR2="\[\e[41;1;35m\]"
COLOR_WHITE="\[\e[41;1;37m\]"
COLOR4="\[\e[43;1;31m\]"
COLOR5="\[\e[43;1;30m\]"
COLOR6="\[\e[0m\[\033[1;33m\]"
COLOR7="\[\e[0m\]"
COLOR8="\[\e[40;1;33m\]"
COLOR9="\[\e[0m\]"
COLOR10="\[\e[1;30m\]"

prompt="${COLOR1} \u ${COLOR2}${COLOR_WHITE} \h ${COLOR4}${COLOR5} \w ${COLOR6}${COLOR7} \n${COLOR8} ⚡️  ${COLOR9}${COLOR10}\[\033[0m\]"

show_prompt() {
	local prompt_str='\n$(show_repository)'
	prompt_str+="${prompt}"
	echo $prompt_str
}
#export PS1="$(show_prompt) "

# perfect prompt
export PS1='\n$(show_repository)\[\033[45;1;37m\] \u \[\033[41;1;35m\]\[\033[41;1;37m\] \h \[\033[43;1;31m\]\[\033[43;1;30m\] \w \[\033[0m\[\033[1;33m\]\033[0m \n\[\033[40;1;33m\] ⚡ \[\033[0m\]\[\033[1;30m\]\[\033[0m\] '
#export PS1='\n$(show_repository)\[\033[45;1;37m\] \u \[\033[41;1;35m\]\[\033[41;1;37m\] \h \[\033[43;1;31m\]\[\033[43;1;30m\] \w \[\033[0m\[\033[1;33m\]\033[0m \n\[\033[40;1;33m\] ⚡︎ \[\033[0m\]\[\033[1;30m\]\[\033[0m\] '
export TERM=xterm-256color

# Bash Exports ---------------------------------------------

# vcprompt environment variables 
export VCPROMPT_STAGED="⚙"
export VCPROMPT_MODIFIED="±"
export VCPROMPT_UNTRACKED="✘"

# some settings to be more colorful 
export CLICOLOR=1
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export LSCOLORS=ExGxFxdxCxDxDxBxBxExEx
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:':'*.hwp=01;35'


# aliases ---------------------------------------------------

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

alias l="ls -l ${colorflag}"
alias ll="ls -la ${colorflag}"
alias lsd='ls -l ${colorflag} | grep "^d"'
alias ls="command ls ${colorflag}"
alias top_commands="history | awk '{print \$2}' | awk 'BEGIN{FS=\"|\"}{print \$1}' | sort | uniq -c | sort -n | tail -n 20 | sort -nr"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"
alias ..="cd .."
alias ...="cd ../../"
alias top='top -o cpu'
alias gs='git status'
alias gl='git lg1'
alias gl2='git lg2'
alias gd='git diff'
alias gm='git mg' 
alias gf='git fc'
alias gb='git br'
alias gc='git co'
alias gcb='git co -b'
alias gp='git push'
alias gpf='git push -f'
alias gbd='git br -D'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gr='git rebase'
alias gri='git rebase -i'
alias grh='git reset --hard'

alias st='open -a "Sublime Text"'
alias typo='open -a Typora'
alias chm-ajax='open /Applications/Google\ Chrome.app/ -n --args --allow-file-access-from-files'

alias ip='ifconfig en4 | awk "{ print $2}" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"'

# Hello Message --------------------------------------------
#echo -e "Kernal Information: " `uname -smr`
#echo -e "`bash --version`"
#echo -ne "Uptime: "; uptime
#echo -ne "Server time is: "; date

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*


# ----------------------------------------------------------
source "$HOME/work/config/bash_work"

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
