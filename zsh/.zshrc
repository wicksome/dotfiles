export DOTFILES_DIR="${${(%):-%x}:A:h:h}"

########################################
# Environment
########################################
export LANG="ko_KR.UTF-8"
export EDITOR="vim"
export CLICOLOR=1

typeset -U path
path=("$HOME/.local/bin" $path)

########################################
# History
########################################
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

########################################
# Completion
########################################
if command -v brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

########################################
# Tools
########################################
if command -v brew &>/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
  [[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

command -v zoxide   &>/dev/null && eval "$(zoxide init zsh --cmd j)"
command -v starship &>/dev/null && eval "$(starship init zsh)"

source "$DOTFILES_DIR/zsh/aliases.zsh"
source "$DOTFILES_DIR/zsh/functions.zsh"

# 머신별 설정 (git에 올리지 않음)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# syntax-highlighting은 마지막에 로드해야 한다
[[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
