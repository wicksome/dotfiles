alias ..="cd .."
alias ...="cd ../.."

alias l="ls -l"
alias ll="ls -al"

alias grep="grep --color=auto"

# git
alias gs="git status"
alias gd="git diff"
alias gb="git branch"
alias gl="git lg1"
alias gc="git commit"
alias gck="git checkout"
alias gsw="git switch"
alias grb="git rebase"
alias grv="git revert"
alias grs="git reset"
alias gmg="git merge"
gln() { git lgn -"${1:-10}"; }   # 현재 브랜치 그래프 n개 (기본 10)

# docker
alias dk="docker"
alias dkc="docker compose"

# system
alias top="top -o cpu"
alias hosts='grep "^[0-9]" /etc/hosts | grep -Ev "^(127.0.0.1|255.255.255.255)"'
alias reload="exec zsh"
