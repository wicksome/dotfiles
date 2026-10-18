#!/usr/bin/env bash
# 여러 번 실행해도 안전하다. 기존 파일은 ~/.dotfiles-backup/<timestamp>/ 로 옮긴다.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_DIR="$(dirname "$DOTFILES_DIR")/dotfiles-private"
PRIVATE_REPO="wicksome/dotfiles-private"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OP_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
SSH_KEY_NAME="wicksome"         # 1Password의 SSH 키 이름: "GitHub wicksome"

info() { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$1"; }

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

info "Claude Code"
if ! command -v claude &>/dev/null && [[ ! -x "$HOME/.local/bin/claude" ]]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

info "Symlinks"
link zsh/.zshrc             "$HOME/.zshrc"
link zsh/.zprofile          "$HOME/.zprofile"
link git/.gitconfig         "$HOME/.gitconfig"
link git/.gitignore_global  "$HOME/.gitignore_global"
link hammerspoon            "$HOME/.hammerspoon"
link ssh/config             "$HOME/.ssh/config"
link ssh/allowed_signers    "$HOME/.ssh/allowed_signers"
link starship/starship.toml "$HOME/.config/starship.toml"

########################################
# GitHub: gh 로그인 → known_hosts → SSH 키 등록
########################################
info "GitHub"
if ! gh auth status -h github.com &>/dev/null; then
  gh auth login -h github.com -p ssh -w -s admin:public_key,admin:ssh_signing_key --skip-ssh-key
fi

if ! grep -q '^github.com ' "$HOME/.ssh/known_hosts" 2>/dev/null; then
  gh api meta --jq '.ssh_keys[]' | sed 's/^/github.com /' >> "$HOME/.ssh/known_hosts"
  chmod 600 "$HOME/.ssh/known_hosts"
  echo "  known_hosts: github.com"
fi

PUBKEY="$HOME/.ssh/$SSH_KEY_NAME.pub"
if [[ ! -f "$PUBKEY" && -S "$OP_AGENT_SOCK" ]]; then
  agent_keys="$(SSH_AUTH_SOCK="$OP_AGENT_SOCK" ssh-add -L 2>/dev/null || true)"
  if grep " GitHub $SSH_KEY_NAME\$" <<<"$agent_keys" > "$PUBKEY"; then
    echo "  public key: $PUBKEY"
  else
    rm -f "$PUBKEY"
  fi
fi

if [[ -f "$PUBKEY" ]]; then
  key_body="$(cut -d' ' -f2 "$PUBKEY")"
  for type in authentication signing; do
    endpoint="user/keys"
    [[ "$type" == "signing" ]] && endpoint="user/ssh_signing_keys"
    registered="$(gh api "$endpoint" --paginate --jq '.[].key')"
    if ! grep -qF "$key_body" <<<"$registered"; then
      gh ssh-key add "$PUBKEY" --type "$type" --title "$(scutil --get ComputerName) (1Password)"
    fi
  done
else
  warn "1Password SSH 키(GitHub $SSH_KEY_NAME)가 없다. README의 '1Password SSH' 단계 후 다시 실행한다."
fi

########################################
# dotfiles-private
########################################
info "dotfiles-private"
if [[ ! -d "$PRIVATE_DIR" ]]; then
  ssh_result="$(ssh -o BatchMode=yes -T git@github.com 2>&1 || true)"
  if grep -q "successfully authenticated" <<<"$ssh_result"; then
    gh repo clone "$PRIVATE_REPO" "$PRIVATE_DIR"
  else
    # SSH가 아직 안 되면 gh 토큰으로 HTTPS 클론
    git -c credential.helper= -c credential.helper='!gh auth git-credential' \
      clone "https://github.com/$PRIVATE_REPO.git" "$PRIVATE_DIR"
  fi
fi

if [[ -x "$PRIVATE_DIR/install.sh" ]]; then
  "$PRIVATE_DIR/install.sh"
fi

info "Done. 새 터미널을 열거나 'exec zsh'를 실행하세요."
