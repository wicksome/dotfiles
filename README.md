# .files

> These are my dotfiles. Take anything you want, but at your own risk.

Apple Silicon macOS 기준.

## Installation

새 맥에서 순서대로. `install.sh`는 여러 번 실행해도 안전하다.

Terminal.app에서 실행한다 (Homebrew 설치에 sudo 비밀번호가 필요하다).

```bash
mkdir -p ~/workspace/wicksome
cd ~/workspace/wicksome
git clone https://github.com/wicksome/dotfiles
cd dotfiles
./install.sh
```

처음에 두 가지를 묻는다. 고른 값은 `~/.config/dotfiles/install.env` 에 저장해 다음부터 묻지 않는다 (`--reconfigure` 로 다시 묻기).

| 질문 | 선택지 (첫 번째가 기본) |
| --- | --- |
| GitHub SSH 키 | `local` 이 머신에 키 생성 · `1password` 1Password SSH Agent · `skip` 건너뜀 |
| 컨테이너 런타임 | `orbstack` · `docker` (Docker Desktop) · `none` |

```bash
./install.sh --github=local --container=docker   # 묻지 않고 실행 (무인 머신)
./install.sh --help
```

중간에 `gh auth login`이 브라우저 로그인을 요청한다. `local`이면 `~/.ssh/id_ed25519`를 만들고(패스프레이즈 권장, macOS 키체인에 저장) GitHub에 인증·서명 키로 등록한 뒤 [dotfiles-private](https://github.com/wicksome/dotfiles-private)를 클론해서 설치한다.

새 키는 `ssh/allowed_signers`에 추가되니 커밋한다 (공개키라 공개해도 된다).

```bash
git remote set-url origin git@github.com:wicksome/dotfiles.git   # 처음 HTTPS로 클론했다면
```

### 1Password를 쓸 때 (`--github=1password`)

1. 1Password 로그인 → 설정 → 개발자 → **SSH 에이전트 사용**
2. 새 항목 → SSH 키 → 이름 **`GitHub wicksome`**, 종류 Ed25519
3. `./install.sh --github=1password` — 공개키를 `~/.ssh/wicksome.pub`로 저장하고, `~/.ssh/config.machine`·`~/.gitconfig.machine`을 만들어 인증·서명을 1Password로 돌린다

`--github=skip`이면 GitHub 설정과 함께 dotfiles-private(brain·claude-config 포함)도 설치하지 않는다.

### install.sh가 하는 일

1. 옵션 결정 (인자 > 저장값 > 질문 > 기본값)
2. Homebrew 설치 (없으면)
3. `brew bundle`로 [Brewfile](Brewfile)의 CLI·앱 설치 (컨테이너 런타임은 고른 것만. 고르지 않은 쪽이 이미 있으면 지우지 않고 경고)
4. [Claude Code](https://claude.com/claude-code) 설치 (없으면, 네이티브 설치기. 자동 업데이트됨)와 [agent-browser](https://github.com/vercel-labs/agent-browser) CLI·브라우저 설치 (npm 전역)
5. 설정 파일을 홈 디렉터리에 심링크 (기존 파일은 `~/.dotfiles-backup/`으로 백업)
6. GitHub: `gh` 로그인, `known_hosts`, SSH 키 준비(`local`: 생성 / `1password`: 공개키 저장) 및 등록
7. `../dotfiles-private` 클론 후 그 레포의 `install.sh` 실행

머신 전용 파일(`~/.ssh/config.machine`, `~/.gitconfig.machine`)은 install.sh가 만든 것만 고치거나 지운다. 직접 만든 파일은 그대로 두고, `local`이면 키 생성도 건너뛴다.

macOS 기본 설정은 [macos](macos)를 참고한다.

## Structure

| Path | Description |
| --- | --- |
| `Brewfile` | 설치할 CLI·앱 목록. 추가 후 `brew bundle` |
| `zsh/` | `.zshrc`, `.zprofile`, aliases, functions. 프롬프트는 [starship](https://starship.rs) |
| `git/` | `.gitconfig`, `.gitignore_global`. 계정별 설정은 dotfiles-private |
| `ghostty/` | 터미널 설정 (`~/.config/ghostty/config.ghostty`). 한글은 D2Coding |
| `starship/` | 프롬프트 설정 (`~/.config/starship.toml`) |
| `ssh/` | `~/.ssh/config`, `allowed_signers`. 개인 키는 머신마다 `~/.ssh/id_ed25519` (또는 1Password) |
| `hammerspoon/` | 앱 실행·창 관리 단축키 ([README](hammerspoon/README.md)) |
| `macos/` | `defaults` 설정 스크립트와 수동 설정 가이드 |

공개하면 안 되는 설정은 [dotfiles-private](https://github.com/wicksome/dotfiles-private)에 둔다. 이 레포는 `~/.zshrc.local`, `~/.gitconfig.local`, `~/.ssh/config.local`을 불러오는 자리만 둔다.

## Manual

- 직접 설치: Orca, BusyCal (App Store 유료 앱, 같은 Apple ID 로 로그인 후 받기)
- 직접 개발 중인 도구는 `~/workspace/wicksome/`에 클론해서 쓴다
  - [quick-mermaid](https://github.com/wicksome/quick-mermaid): 터미널에서 mermaid 미리보기
