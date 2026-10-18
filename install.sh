#!/usr/bin/env bash
# 여러 번 실행해도 안전하다. 기존 파일은 ~/.dotfiles-backup/<timestamp>/ 로 옮긴다.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;32m==>\033[0m %s\n' "$1"; }

# $1: dotfiles 안의 경로, $2: 링크할 위치
link() {
  local src="$DOTFILES_DIR/$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    echo "  backup: $dst -> $BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$dst")"
  [[ "$dst" == "$HOME/.ssh/"* ]] && chmod 700 "$HOME/.ssh"
  ln -s "$src" "$dst"
  echo "  link: $dst -> $src"
}

info "Homebrew"
if ! command -v brew &>/dev/null && [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

info "brew bundle"
brew bundle --file="$DOTFILES_DIR/Brewfile"

info "Symlinks"
link zsh/.zshrc             "$HOME/.zshrc"
link zsh/.zprofile          "$HOME/.zprofile"
link git/.gitconfig         "$HOME/.gitconfig"
link git/.gitignore_global  "$HOME/.gitignore_global"
link hammerspoon            "$HOME/.hammerspoon"
link ssh/config             "$HOME/.ssh/config"

info "Done. 새 터미널을 열거나 'exec zsh'를 실행하세요."
