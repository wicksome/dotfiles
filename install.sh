#!/usr/bin/env bash
# 여러 번 실행해도 안전하다. 기존 파일은 ~/.dotfiles-backup/<timestamp>/ 로 옮긴다.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_DIR="$(dirname "$DOTFILES_DIR")/dotfiles-private"
PRIVATE_REPO="wicksome/dotfiles-private"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
STATE_FILE="$HOME/.config/dotfiles/install.env"   # 이 머신에서 고른 옵션 (레포 밖)
OP_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
OP_KEY_NAME="wicksome"          # 1Password의 SSH 키 이름: "GitHub wicksome"
LOCAL_KEY="$HOME/.ssh/id_ed25519"
MANAGED_MARK="# managed by dotfiles/install.sh"

info() { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$1"; }

usage() {
  cat <<'EOF'
Usage: ./install.sh [--github=local|1password|skip] [--container=orbstack|docker|none] [--reconfigure]

  --github       local     이 머신에 SSH 키를 만들어 GitHub 인증·서명에 쓴다 (기본)
                 1password 1Password SSH Agent의 키를 쓴다
                 skip      GitHub 설정과 dotfiles-private 설치를 건너뛴다
  --container    orbstack (기본) | docker (Docker Desktop) | none
  --reconfigure  저장된 선택을 무시하고 다시 묻는다

처음 실행할 때 고른 값은 ~/.config/dotfiles/install.env 에 저장해 다음부터 묻지 않는다.
터미널이 아니면(무인 실행) 묻지 않고 저장값 또는 기본값을 쓴다.
EOF
}

########################################
# 옵션: 인자 > 저장값 > (터미널이면) 질문 > 기본값
########################################
GITHUB_MODE="" CONTAINER="" RECONFIGURE=0
for arg in "$@"; do
  case "$arg" in
    --github=*)    GITHUB_MODE="${arg#*=}" ;;
    --container=*) CONTAINER="${arg#*=}" ;;
    --reconfigure) RECONFIGURE=1 ;;
    -h|--help)     usage; exit 0 ;;
    *)             echo "알 수 없는 옵션: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

saved() { [[ -f "$STATE_FILE" ]] && sed -n "s/^$1=//p" "$STATE_FILE" | tail -1; }
if [[ "$RECONFIGURE" == 0 ]]; then
  [[ -n "$GITHUB_MODE" ]] || GITHUB_MODE="$(saved GITHUB_MODE || true)"
  [[ -n "$CONTAINER" ]]   || CONTAINER="$(saved CONTAINER || true)"
fi

# $1: 질문, 나머지: "값|설명" (첫 번째가 기본값). 고른 값을 stdout으로 낸다
choose() {
  local question="$1" i=1 opt reply
  shift
  printf '\n%s\n' "$question" >&2
  for opt in "$@"; do
    printf '  %d) %-10s %s\n' "$i" "${opt%%|*}" "${opt#*|}" >&2
    i=$((i + 1))
  done
  while true; do
    read -r -p "  번호 [1]: " reply </dev/tty
    reply="${reply:-1}"
    if [[ "$reply" =~ ^[0-9]+$ ]] && (( reply >= 1 && reply <= $# )); then
      opt="${!reply}"
      echo "${opt%%|*}"
      return
    fi
  done
}

interactive() { [[ -t 0 && -t 1 ]]; }

if [[ -z "$GITHUB_MODE" ]]; then
  GITHUB_MODE=local
  interactive && GITHUB_MODE="$(choose "GitHub SSH 키" \
    "local|이 머신에 키를 만들어 저장 (~/.ssh/id_ed25519)" \
    "1password|1Password SSH Agent의 키 사용" \
    "skip|GitHub 설정 건너뜀 (dotfiles-private·brain·claude-config도 설치 안 함)")"
fi
if [[ -z "$CONTAINER" ]]; then
  CONTAINER=orbstack
  interactive && CONTAINER="$(choose "컨테이너 런타임" \
    "orbstack|OrbStack" \
    "docker|Docker Desktop" \
    "none|설치 안 함")"
fi

case "$GITHUB_MODE" in local|1password|skip) ;; *) echo "잘못된 --github: $GITHUB_MODE" >&2; exit 1 ;; esac
case "$CONTAINER" in orbstack|docker|none) ;; *) echo "잘못된 --container: $CONTAINER" >&2; exit 1 ;; esac

mkdir -p "$(dirname "$STATE_FILE")"
printf 'GITHUB_MODE=%s\nCONTAINER=%s\n' "$GITHUB_MODE" "$CONTAINER" > "$STATE_FILE"
info "옵션: github=$GITHUB_MODE container=$CONTAINER ($STATE_FILE)"

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

# 머신 전용 파일(~/.ssh/config.machine 등)은 install.sh가 만든 것만 고치거나 지운다.
# 직접 만든 파일은 건드리지 않는다.
managed_or_absent() { [[ ! -e "$1" ]] || grep -qxF "$MANAGED_MARK" "$1"; }

# $1: 경로, stdin: 내용
write_machine_file() {
  if managed_or_absent "$1"; then
    { echo "$MANAGED_MARK"; cat; } > "$1"
    echo "  write: $1"
  else
    cat >/dev/null
    warn "$1 은 직접 만든 파일이라 그대로 둔다"
  fi
}

remove_machine_file() {
  if [[ -e "$1" ]] && grep -qxF "$MANAGED_MARK" "$1"; then
    rm "$1"
    echo "  remove: $1"
  fi
}

info "Homebrew"
if ! command -v brew &>/dev/null && [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

info "brew bundle"
# brew는 HOMEBREW_로 시작하지 않는 환경변수를 Brewfile에 넘기지 않는다
HOMEBREW_DOTFILES_CONTAINER="$CONTAINER" brew bundle --file="$DOTFILES_DIR/Brewfile"

# 고르지 않은 런타임은 지우지 않는다 (이미지·볼륨이 같이 사라진다)
[[ "$CONTAINER" != orbstack && -d /Applications/OrbStack.app ]] && warn "OrbStack이 설치돼 있다. 필요 없으면 직접 지운다: brew uninstall --cask orbstack"
[[ "$CONTAINER" != docker && -d /Applications/Docker.app ]] && warn "Docker Desktop이 설치돼 있다. 필요 없으면 직접 지운다: brew uninstall --cask docker-desktop"

# cask 폰트에 붙은 quarantine 때문에 macOS가 폰트를 활성화하지 않는 경우가 있어 직접 등록한다
info "Fonts"
for font in "$HOME"/Library/Fonts/D2Coding*.ttc; do
  [[ -f "$font" ]] || continue
  xattr -d com.apple.quarantine "$font" 2>/dev/null || true
  osascript -l JavaScript -e "ObjC.import('CoreText');
    \$.CTFontManagerRegisterFontsForURL(\$.NSURL.fileURLWithPath('$font'), 2, Ref())" >/dev/null 2>&1 || true
done

info "Claude Code"
if ! command -v claude &>/dev/null && [[ ! -x "$HOME/.local/bin/claude" ]]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Claude Code의 agent-browser 스킬이 쓰는 헤드리스 브라우저 CLI
info "agent-browser"
if ! command -v agent-browser &>/dev/null; then
  npm install -g agent-browser
fi
if ! compgen -G "$HOME/.agent-browser/browsers/*" >/dev/null; then
  agent-browser install
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
link ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty"

if [[ "$GITHUB_MODE" == skip ]]; then
  warn "GitHub 건너뜀: dotfiles-private(brain·claude-config 포함)도 설치하지 않는다. 나중에 ./install.sh --github=local"
  info "Done. 새 터미널을 열거나 'exec zsh'를 실행하세요."
  exit 0
fi

########################################
# GitHub: gh 로그인 → known_hosts → SSH 키 준비 → GitHub 등록
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

PUBKEY="" KEY_LABEL=""
case "$GITHUB_MODE" in
  local)
    remove_machine_file "$HOME/.ssh/config.machine"
    remove_machine_file "$HOME/.gitconfig.machine"
    if ! managed_or_absent "$HOME/.ssh/config.machine"; then
      # 직접 만든 머신 설정이 키를 정한다 (예: 무인 맥미니). 새 키를 만들지 않는다
      warn "~/.ssh/config.machine 이 키를 지정하고 있어 키 생성·등록을 건너뛴다"
    else
      if [[ ! -f "$LOCAL_KEY" ]]; then
        if interactive; then
          echo "  패스프레이즈를 권장한다. 입력하면 macOS 키체인에 저장돼 다시 묻지 않는다."
          ssh-keygen -t ed25519 -C "$(scutil --get ComputerName)" -f "$LOCAL_KEY"
        else
          ssh-keygen -t ed25519 -C "$(scutil --get ComputerName)" -f "$LOCAL_KEY" -N '' -q
        fi
        echo "  key: $LOCAL_KEY"
      fi
      if ! ssh-keygen -y -P '' -f "$LOCAL_KEY" >/dev/null 2>&1; then
        ssh-add --apple-use-keychain "$LOCAL_KEY" || warn "ssh-agent에 키를 올리지 못했다. 첫 git 사용 때 패스프레이즈를 묻는다"
      fi
      PUBKEY="$LOCAL_KEY.pub" KEY_LABEL="local"
    fi
    ;;
  1password)
    OP_PUBKEY="$HOME/.ssh/$OP_KEY_NAME.pub"
    if [[ ! -f "$OP_PUBKEY" && -S "$OP_AGENT_SOCK" ]]; then
      agent_keys="$(SSH_AUTH_SOCK="$OP_AGENT_SOCK" ssh-add -L 2>/dev/null || true)"
      if grep " GitHub $OP_KEY_NAME\$" <<<"$agent_keys" > "$OP_PUBKEY"; then
        echo "  public key: $OP_PUBKEY"
      else
        rm -f "$OP_PUBKEY"
      fi
    fi
    if [[ -f "$OP_PUBKEY" ]]; then
      # ssh/config는 먼저 읽은 값이, .gitconfig는 나중에 읽은 값이 이긴다. 둘 다 기본 설정을 덮어쓴다
      write_machine_file "$HOME/.ssh/config.machine" <<EOF
# 1Password SSH Agent의 키로 GitHub에 인증한다 (install.sh --github=1password)
Host *
    IdentityAgent "$OP_AGENT_SOCK"
Host github.com
    IdentityFile ~/.ssh/$OP_KEY_NAME.pub
    IdentitiesOnly yes
EOF
      write_machine_file "$HOME/.gitconfig.machine" <<EOF
# 1Password로 커밋에 서명한다 (install.sh --github=1password)
[user]
	signingkey = ~/.ssh/$OP_KEY_NAME.pub
[gpg "ssh"]
	program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
EOF
      PUBKEY="$OP_PUBKEY" KEY_LABEL="1Password"
    else
      warn "1Password SSH 키(GitHub $OP_KEY_NAME)가 없다. README의 '1Password를 쓸 때' 단계 후 다시 실행한다."
    fi
    ;;
esac

if [[ -n "$PUBKEY" ]]; then
  key_body="$(cut -d' ' -f2 "$PUBKEY")"
  for type in authentication signing; do
    endpoint="user/keys"
    [[ "$type" == "signing" ]] && endpoint="user/ssh_signing_keys"
    registered="$(gh api "$endpoint" --paginate --jq '.[].key')"
    if ! grep -qF "$key_body" <<<"$registered"; then
      gh ssh-key add "$PUBKEY" --type "$type" --title "$(scutil --get ComputerName) ($KEY_LABEL)"
    fi
  done

  # 내 서명을 git log에서 검증하려면 공개키가 allowed_signers에 있어야 한다 (공개키라 공개 레포에 둬도 된다)
  signers="$DOTFILES_DIR/ssh/allowed_signers"
  if ! grep -qF "$key_body" "$signers"; then
    echo "$(git config -f "$DOTFILES_DIR/git/.gitconfig" user.email) $(cut -d' ' -f1,2 "$PUBKEY")" >> "$signers"
    warn "ssh/allowed_signers 에 이 머신의 공개키를 추가했다. 커밋한다."
  fi
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
