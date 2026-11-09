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
Usage: ./install.sh [--machine=personal|work] [--github=local|1password|skip] [--container=orbstack|docker|none]
                    [--overlay-repo=<owner/repo>] [--overlay=<dir>] [--reconfigure]

  --machine       personal  개인 맥 (기본)
                  work      업무 맥. 개인 설정 위에 업무 overlay 레포를 받아 얹는다
  --github        local     이 머신에 SSH 키를 만들어 GitHub 인증·서명에 쓴다 (personal 기본)
                  1password 1Password SSH Agent의 키를 쓴다
                  skip      GitHub 설정과 dotfiles-private 설치를 건너뛴다
                  (work 는 기본 키를 만들지 않는다. 계정별 키를 dotfiles-private 과 overlay 가 만든다)
  --container     orbstack | docker (Docker Desktop) | none. 기본: personal orbstack, work docker
  --overlay-repo  work 의 overlay 레포 (owner/repo). 없으면 묻는다. 로그인된 gh 계정 중 받을 수 있는 계정으로 받는다
  --overlay       overlay 를 둘 경로. 없으면 업무 레포 루트를 묻고 <루트>/<owner>/<repo> 로 한다
  --reconfigure   저장된 선택을 무시하고 다시 묻는다

순서: 이 레포 → dotfiles-private → (work 면) overlay. 각 단계는 여러 번 실행해도 안전하다.

처음 실행할 때 고른 값은 ~/.config/dotfiles/install.env 에 저장해 다음부터 묻지 않는다.
터미널이 아니면(무인 실행) 묻지 않고 저장값 또는 기본값을 쓴다.
EOF
}

########################################
# 옵션: 인자 > 저장값 > (터미널이면) 질문 > 기본값
########################################
MACHINE="" GITHUB_MODE="" CONTAINER="" OVERLAY="" OVERLAY_REPO="" RECONFIGURE=0
for arg in "$@"; do
  case "$arg" in
    --machine=*)      MACHINE="${arg#*=}" ;;
    --github=*)       GITHUB_MODE="${arg#*=}" ;;
    --container=*)    CONTAINER="${arg#*=}" ;;
    --overlay-repo=*) OVERLAY_REPO="${arg#*=}" ;;
    --overlay=*)      OVERLAY="${arg#*=}"; OVERLAY="${OVERLAY/#\~/$HOME}" ;;
    --reconfigure)    RECONFIGURE=1 ;;
    -h|--help)        usage; exit 0 ;;
    *)                echo "알 수 없는 옵션: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

saved() { [[ -f "$STATE_FILE" ]] && sed -n "s/^$1=//p" "$STATE_FILE" | tail -1; }
if [[ "$RECONFIGURE" == 0 ]]; then
  [[ -n "$MACHINE" ]]      || MACHINE="$(saved MACHINE || true)"
  [[ -n "$GITHUB_MODE" ]]  || GITHUB_MODE="$(saved GITHUB_MODE || true)"
  [[ -n "$CONTAINER" ]]    || CONTAINER="$(saved CONTAINER || true)"
  [[ -n "$OVERLAY_REPO" ]] || OVERLAY_REPO="$(saved OVERLAY_REPO || true)"
  [[ -n "$OVERLAY" ]]      || OVERLAY="$(saved OVERLAY || true)"
fi
# 예전 저장값(OVERLAY 만 있음)과 --overlay 만 준 경우는 work 로 본다
[[ -z "$MACHINE" && -n "$OVERLAY$OVERLAY_REPO" ]] && MACHINE=work

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

# $1: 질문, $2: 기본값. 입력값(없으면 기본값)을 stdout으로 낸다
ask() {
  local reply
  read -r -p "$1${2:+ [$2]}: " reply </dev/tty
  echo "${reply:-$2}"
}

interactive() { [[ -t 0 && -t 1 ]]; }

if [[ -z "$MACHINE" ]]; then
  MACHINE=personal
  interactive && MACHINE="$(choose "이 맥" \
    "personal|개인 맥" \
    "work|업무 맥 (개인 설정 위에 업무 overlay 레포를 얹는다)")"
fi
case "$MACHINE" in personal|work) ;; *) echo "잘못된 --machine: $MACHINE" >&2; exit 1 ;; esac

if [[ "$MACHINE" == work ]]; then
  # 업무 맥은 기본 키를 두지 않는다. agent 에 올라간 기본 키가 계정별 -i 키보다 먼저 쓰여 다른 계정으로 인증된다
  [[ "$GITHUB_MODE" == skip ]] && { echo "work 는 --github=skip 과 함께 쓸 수 없다 (dotfiles-private 이 overlay 를 부른다)" >&2; exit 1; }
  GITHUB_MODE=account
  if [[ -z "$OVERLAY" ]]; then
    if [[ -z "$OVERLAY_REPO" ]]; then
      interactive || { echo "work 는 --overlay-repo=<owner/repo> 가 필요하다" >&2; exit 1; }
      OVERLAY_REPO="$(ask "업무 overlay 레포 (owner/repo)" "")"
    fi
    [[ "$OVERLAY_REPO" == */* ]] || { echo "잘못된 --overlay-repo: $OVERLAY_REPO (owner/repo)" >&2; exit 1; }
    root="$HOME/work"
    interactive && root="$(ask "업무 레포 루트 (overlay 는 <루트>/$OVERLAY_REPO)" "$root")"
    root="${root/#\~/$HOME}"
    OVERLAY="${root%/}/$OVERLAY_REPO"
  fi
  if [[ -z "$CONTAINER" ]]; then
    CONTAINER=docker
    interactive && CONTAINER="$(choose "컨테이너 런타임 (OrbStack 은 회사 업무에 유료 라이선스가 필요하다)" \
      "docker|Docker Desktop" \
      "none|설치 안 함" \
      "orbstack|OrbStack")"
  fi
else
  [[ -z "$OVERLAY$OVERLAY_REPO" ]] || { echo "--overlay·--overlay-repo 는 --machine=work 에서만 쓴다" >&2; exit 1; }
fi

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

case "$GITHUB_MODE" in local|1password|skip|account) ;; *) echo "잘못된 --github: $GITHUB_MODE" >&2; exit 1 ;; esac
case "$CONTAINER" in orbstack|docker|none) ;; *) echo "잘못된 --container: $CONTAINER" >&2; exit 1 ;; esac

mkdir -p "$(dirname "$STATE_FILE")"
{
  printf 'MACHINE=%s\nGITHUB_MODE=%s\nCONTAINER=%s\n' "$MACHINE" "$GITHUB_MODE" "$CONTAINER"
  [[ -z "$OVERLAY_REPO" ]] || printf 'OVERLAY_REPO=%s\n' "$OVERLAY_REPO"
  [[ -z "$OVERLAY" ]] || printf 'OVERLAY=%s\n' "$OVERLAY"
} > "$STATE_FILE"
info "옵션: machine=$MACHINE github=$GITHUB_MODE container=$CONTAINER${OVERLAY:+ overlay=$OVERLAY} ($STATE_FILE)"

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
for font in "$HOME"/Library/Fonts/D2Coding*.ttc "$HOME"/Library/Fonts/JetBrainsMono*.ttf; do
  [[ -f "$font" ]] || continue
  xattr -d com.apple.quarantine "$font" 2>/dev/null || true
  osascript -l JavaScript -e "ObjC.import('CoreText');
    \$.CTFontManagerRegisterFontsForURL(\$.NSURL.fileURLWithPath('$font'), 2, Ref())" >/dev/null 2>&1 || true
done

# App Store 앱. App Store 에 로그인돼 있어야 받는다. 실패해도 설치를 멈추지 않는다
info "App Store"
MAS_APPS=("937984704:Amphetamine")   # "<App Store id>:<앱 이름>"
for app in "${MAS_APPS[@]}"; do
  [[ -d "/Applications/${app#*:}.app" ]] && continue
  if mas install "${app%%:*}" >/dev/null 2>&1; then
    echo "  install: ${app#*:}"
  else
    warn "${app#*:} 을 받지 못했다. App Store 에 로그인한 뒤: mas install ${app%%:*}"
  fi
done

# Orca (AI 에이전트 터미널). Homebrew cask 가 없어 GitHub 최신 릴리즈의 Apple Silicon zip 을 받는다. 앱이 스스로 업데이트한다
info "Orca"
if [[ ! -d /Applications/Orca.app ]]; then
  orca_url="$(curl -fsSL https://api.github.com/repos/stablyai/orca/releases/latest |
    jq -r '.assets[] | select(.name | test("^Orca-.*-arm64-mac\\.zip$")) | .browser_download_url' | head -1)"
  if [[ -n "$orca_url" ]]; then
    orca_tmp="$(mktemp -d)"
    curl -fsSL -o "$orca_tmp/orca.zip" "$orca_url" &&
      ditto -x -k "$orca_tmp/orca.zip" /Applications &&
      xattr -dr com.apple.quarantine /Applications/Orca.app 2>/dev/null
    rm -rf "$orca_tmp"
    if [[ -d /Applications/Orca.app ]]; then
      echo "  install: Orca ($(basename "$orca_url"))"
    else
      warn "Orca 설치 실패: $orca_url"
    fi
  else
    warn "Orca 릴리즈를 찾지 못했다. https://github.com/stablyai/orca/releases 에서 직접 받는다"
  fi
fi

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
link vim/.vimrc             "$HOME/.vimrc"
link hammerspoon            "$HOME/.hammerspoon"
link ssh/config             "$HOME/.ssh/config"
link ssh/allowed_signers    "$HOME/.ssh/allowed_signers"
link starship/starship.toml "$HOME/.config/starship.toml"
link ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty"

# vim 플러그인 (vim-plug). 없는 것만 받는다
info "vim plugins"
vim -Es -u "$HOME/.vimrc" -i NONE -c 'PlugInstall --sync' -c 'qa' >/dev/null 2>&1 || warn "vim 플러그인 설치 실패. vim 을 열면 다시 받는다"

if [[ "$GITHUB_MODE" == skip ]]; then
  warn "GitHub 건너뜀: dotfiles-private(brain·claude-config 포함)도 설치하지 않는다. 나중에 ./install.sh --github=local"
  info "Done. 새 터미널을 열거나 'exec zsh'를 실행하세요."
  exit 0
fi

########################################
# GitHub: gh 로그인 → known_hosts → SSH 키 준비 → GitHub 등록
########################################
info "GitHub"
# 다른 계정이 이미 로그인돼 있어도 이 계정(wicksome)을 더한다. dotfiles-private 을 이 계정 토큰으로 받는다
# gh auth status | grep -q 는 pipefail 에서 SIGPIPE 로 가끔 실패한다. 변수에 받아 비교한다
gh_status="$(gh auth status -h github.com 2>&1 || true)"
if [[ "$gh_status" != *"account $OP_KEY_NAME "* ]]; then
  gh auth login -h github.com -p ssh -w -s admin:public_key,admin:ssh_signing_key --skip-ssh-key
fi

if ! grep -q '^github.com ' "$HOME/.ssh/known_hosts" 2>/dev/null; then
  gh api meta --jq '.ssh_keys[]' | sed 's/^/github.com /' >> "$HOME/.ssh/known_hosts"
  chmod 600 "$HOME/.ssh/known_hosts"
  echo "  known_hosts: github.com"
fi

PUBKEY="" KEY_LABEL=""
# account(업무 맥)는 기본 키를 두지 않는다. agent 에 올라간 기본 키가 계정별 -i 키보다 먼저 쓰여 다른 계정으로 인증된다
[[ "$GITHUB_MODE" == account ]] && info "기본 SSH 키 건너뜀: 계정별 키를 dotfiles-private·overlay 가 만든다"
case "$GITHUB_MODE" in
  local)
    remove_machine_file "$HOME/.ssh/config.machine"
    remove_machine_file "$HOME/.gitconfig.machine"
    if ! managed_or_absent "$HOME/.ssh/config.machine"; then
      # 직접 만든 머신 설정이 키를 정한다 (예: 무인 맥미니). 새 키를 만들지 않는다
      warn "$HOME/.ssh/config.machine 이 키를 지정하고 있어 키 생성·등록을 건너뛴다"
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
fi

########################################
# 업무 overlay (machine=work): 로그인된 gh 계정 중 받을 수 있는 계정의 토큰으로 HTTPS 클론한다.
# 아무 계정으로도 못 받으면 로그인을 한 번 더 받는다 (업무 계정)
########################################
# $1: owner/repo, $2: 받을 경로. 성공하면 0
clone_with_any_account() {
  local account status
  status="$(gh auth status -h github.com 2>&1 || true)"
  while read -r account; do
    [[ -n "$account" ]] || continue
    GIT_TERMINAL_PROMPT=0 GH_TOKEN="$(gh auth token -h github.com -u "$account")" git -c credential.helper= \
      -c credential.helper='!gh auth git-credential' clone -q "https://github.com/$1.git" "$2" 2>/dev/null &&
      { echo "  clone: $1 -> $2 ($account)"; return 0; }
  done < <(sed -n 's/.*account \([^ ]*\) .*/\1/p' <<<"$status")
  return 1
}
if [[ "$MACHINE" == work ]]; then
  info "업무 overlay ($OVERLAY)"
  if [[ ! -d "$OVERLAY/.git" ]]; then
    [[ -n "$OVERLAY_REPO" ]] || { echo "overlay 가 없고 --overlay-repo 도 없다: $OVERLAY" >&2; exit 1; }
    mkdir -p "$(dirname "$OVERLAY")"
    if ! clone_with_any_account "$OVERLAY_REPO" "$OVERLAY"; then
      echo "  $OVERLAY_REPO 를 받을 수 있는 gh 계정이 없다. 그 레포의 계정으로 로그인한다 (브라우저)"
      gh auth login -h github.com -p https -w -s admin:public_key
      clone_with_any_account "$OVERLAY_REPO" "$OVERLAY" || { echo "$OVERLAY_REPO 를 받지 못했다" >&2; exit 1; }
    fi
  fi
  [[ -x "$OVERLAY/install.sh" ]] || { echo "overlay 에 install.sh 가 없다: $OVERLAY" >&2; exit 1; }
fi

########################################
# dotfiles-private
########################################
info "dotfiles-private"
if [[ ! -d "$PRIVATE_DIR" ]]; then
  ssh_result="$(ssh -o BatchMode=yes -T git@github.com 2>&1 || true)"
  if grep -q "Hi $OP_KEY_NAME!" <<<"$ssh_result"; then
    git clone "git@github.com:$PRIVATE_REPO.git" "$PRIVATE_DIR"
  else
    # SSH가 아직 안 되면(overlay 머신은 이 단계에 키가 없다) 이 계정의 gh 토큰으로 HTTPS 클론.
    # gh 활성 계정이 다른 계정일 수 있어 GH_TOKEN 으로 계정을 지정한다 (gh 의 credential helper 가 이 값을 쓴다)
    GH_TOKEN="$(gh auth token -h github.com -u "$OP_KEY_NAME")" git -c credential.helper= \
      -c credential.helper='!gh auth git-credential' clone "https://github.com/$PRIVATE_REPO.git" "$PRIVATE_DIR"
  fi
fi

if [[ -x "$PRIVATE_DIR/install.sh" ]]; then
  if [[ "$MACHINE" == work ]]; then
    # dotfiles-private 이 개인 키·링크를 한 뒤 overlay 의 install.sh 를 부른다
    DOTFILES_PROFILE=work DOTFILES_WORK_DIR="$OVERLAY" "$PRIVATE_DIR/install.sh"
  else
    DOTFILES_PROFILE=personal "$PRIVATE_DIR/install.sh"
  fi
fi

# 내 서명을 git log에서 검증하려면 공개키가 allowed_signers에 있어야 한다 (공개키라 공개 레포에 둬도 된다).
# 이메일은 비공개 층이 정하므로 dotfiles-private 설치 뒤에 읽는다
if [[ -n "$PUBKEY" ]]; then
  signers="$DOTFILES_DIR/ssh/allowed_signers"
  signer_email="$(git config --global --includes user.email || true)"
  if [[ -z "$signer_email" ]]; then
    warn "user.email 이 없어 ssh/allowed_signers 에 공개키를 추가하지 못했다. dotfiles-private 설치 후 다시 실행한다"
  elif ! grep -qF "$(cut -d' ' -f2 "$PUBKEY")" "$signers"; then
    echo "$signer_email $(cut -d' ' -f1,2 "$PUBKEY")" >> "$signers"
    warn "ssh/allowed_signers 에 이 머신의 공개키를 추가했다. 커밋한다."
  fi
fi

# 처음에 HTTPS 로 받았으면 SSH 로 바꾼다. 키는 dotfiles-private 이 연결한 설정이 고르므로 그 뒤에 바꾸고,
# 이 레포 설정으로 SSH 접속이 되는지 먼저 확인한다
origin_url="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"
if [[ "$origin_url" == https://github.com/* ]]; then
  ssh_url="git@github.com:${origin_url#https://github.com/}"
  [[ "$ssh_url" == *.git ]] || ssh_url="$ssh_url.git"
  if git -C "$DOTFILES_DIR" -c core.sshCommand="$(git -C "$DOTFILES_DIR" config core.sshCommand || echo ssh) -o BatchMode=yes" \
      ls-remote "$ssh_url" HEAD >/dev/null 2>&1; then
    git -C "$DOTFILES_DIR" remote set-url origin "$ssh_url"
    echo "  remote: $DOTFILES_DIR -> SSH"
  else
    warn "SSH 로 $ssh_url 에 접속하지 못해 remote 를 HTTPS 로 둔다"
  fi
fi

info "Done. 새 터미널을 열거나 'exec zsh'를 실행하세요."
