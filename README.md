# .files

> These are my dotfiles. Take anything you want, but at your own risk.

Apple Silicon macOS 기준.

## Installation

새 맥에서 순서대로. `install.sh`는 여러 번 실행해도 안전하다.

### 1. 첫 실행

Terminal.app에서 실행한다 (Homebrew 설치에 sudo 비밀번호가 필요하다).

```bash
mkdir -p ~/workspace/wicksome
cd ~/workspace/wicksome
git clone https://github.com/wicksome/dotfiles
cd dotfiles
./install.sh
```

중간에 `gh auth login`이 브라우저 로그인을 요청한다. 1Password SSH 키가 아직 없으니 마지막에 경고가 나오는 게 정상이다.

### 2. 1Password SSH

1. 1Password 로그인 → 설정 → 개발자 → **SSH 에이전트 사용**
2. 새 항목 → SSH 키 → 이름 **`GitHub wicksome`**, 종류 Ed25519

### 3. 다시 실행

```bash
./install.sh
```

공개키를 `~/.ssh/wicksome.pub`로 저장하고, GitHub에 인증·서명 키로 등록하고, [dotfiles-private](https://github.com/wicksome/dotfiles-private)를 클론해서 설치한다.

```bash
git remote set-url origin git@github.com:wicksome/dotfiles.git   # 처음 HTTPS로 클론했다면
```

### install.sh가 하는 일

1. Homebrew 설치 (없으면)
2. `brew bundle`로 [Brewfile](Brewfile)의 CLI·앱 설치
3. [Claude Code](https://claude.com/claude-code) 설치 (없으면, 네이티브 설치기. 자동 업데이트됨)
4. 설정 파일을 홈 디렉터리에 심링크 (기존 파일은 `~/.dotfiles-backup/`으로 백업)
5. GitHub: `gh` 로그인, `known_hosts`, 1Password SSH 공개키 저장 및 등록
6. `../dotfiles-private` 클론 후 그 레포의 `install.sh` 실행

macOS 기본 설정은 [macos](macos)를 참고한다.

## Structure

| Path | Description |
| --- | --- |
| `Brewfile` | 설치할 CLI·앱 목록. 추가 후 `brew bundle` |
| `zsh/` | `.zshrc`, `.zprofile`, aliases, functions. 프롬프트는 [starship](https://starship.rs) |
| `git/` | `.gitconfig`, `.gitignore_global`. 계정별 설정은 dotfiles-private |
| `starship/` | 프롬프트 설정 (`~/.config/starship.toml`) |
| `ssh/` | `~/.ssh/config`. 개인 키는 1Password SSH Agent에 보관 |
| `hammerspoon/` | 앱 실행·창 관리 단축키 ([README](hammerspoon/README.md)) |
| `macos/` | `defaults` 설정 스크립트와 수동 설정 가이드 |

공개하면 안 되는 설정은 [dotfiles-private](https://github.com/wicksome/dotfiles-private)에 둔다. 이 레포는 `~/.zshrc.local`, `~/.gitconfig.local`, `~/.ssh/config.local`을 불러오는 자리만 둔다.

## Manual

- 직접 설치: Orca, BusyCal
- 직접 개발 중인 도구는 `~/workspace/wicksome/`에 클론해서 쓴다
  - [quick-mermaid](https://github.com/wicksome/quick-mermaid): 터미널에서 mermaid 미리보기
