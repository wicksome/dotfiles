# .files

> These are my dotfiles. Take anything you want, but at your own risk.

Apple Silicon macOS 기준.

## Installation

새 맥에서 clone 하고 `install.sh` 하나만 실행한다. 개인 맥·업무 맥을 고르면 나머지는 순서대로 진행된다. 여러 번 실행해도 안전하다.

Terminal.app에서 실행한다 (Homebrew 설치에 sudo 비밀번호가 필요하다). `git` 이 없으면 macOS 가 Command Line Tools 설치를 먼저 띄운다.

```bash
git clone https://github.com/wicksome/dotfiles ~/workspace/wicksome/dotfiles
~/workspace/wicksome/dotfiles/install.sh
```

처음에 묻는 것. 고른 값은 `~/.config/dotfiles/install.env` 에 저장해 다음부터 묻지 않는다 (`--reconfigure` 로 다시 묻기).

| 질문 | 개인 맥 (`personal`) | 업무 맥 (`work`) |
| --- | --- | --- |
| 이 맥 | `personal` (기본) | `work` |
| GitHub SSH 키 | `local` 이 머신에 키 생성 · `1password` · `skip` | 묻지 않는다. 기본 키 없이 계정별 키만 둔다 |
| 업무 overlay 레포 | - | `owner/repo` 와 업무 레포 루트. overlay 는 `<루트>/<owner>/<repo>` 에 받는다 |
| 컨테이너 런타임 | `orbstack` (기본) · `docker` · `none` | `docker` (기본, OrbStack 은 회사 업무에 유료) · `none` · `orbstack` |

설치 중 입력하는 것은 gh 브라우저 로그인, sudo 비밀번호, SSH 키 패스프레이즈(Enter 로 비워도 된다)뿐이다.

- 개인 맥: 개인 계정으로 gh 로그인 → `~/.ssh/id_ed25519` 생성·등록 → [dotfiles-private](https://github.com/wicksome/dotfiles-private) (brain·claude-config)
- 업무 맥: 개인 계정 gh 로그인 → overlay 를 받을 수 있는 계정이 없으면 그 계정 gh 로그인 → overlay 클론 → dotfiles-private(프로필 work: 개인 계정 키 `~/.ssh/wicksome`, 개인 레포 계정) → overlay 의 `install.sh`

```bash
./install.sh --machine=personal --github=local --container=docker              # 묻지 않고 실행 (무인 머신)
./install.sh --machine=work --overlay-repo=<owner/repo> --overlay=<경로>        # 업무 맥, 묻지 않고 실행
./install.sh --help
```

새 키는 `ssh/allowed_signers`에 추가되니 커밋한다 (공개키라 공개해도 된다).

처음 HTTPS 로 클론했으면 install.sh 가 마지막에 SSH 접속을 확인하고 remote 를 SSH 로 바꾼다.

### 1Password를 쓸 때 (`--github=1password`)

1. 1Password 로그인 → 설정 → 개발자 → **SSH 에이전트 사용**
2. 새 항목 → SSH 키 → 이름 **`GitHub wicksome`**, 종류 Ed25519
3. `./install.sh --github=1password` — 공개키를 `~/.ssh/wicksome.pub`로 저장하고, `~/.ssh/config.machine`·`~/.gitconfig.machine`을 만들어 인증·서명을 1Password로 돌린다

`--github=skip`이면 GitHub 설정과 함께 dotfiles-private(brain·claude-config 포함)도 설치하지 않는다.

### 업무 맥 (`--machine=work`)

- 기본 키(`~/.ssh/id_ed25519`)를 만들지 않는다. 키는 계정마다 따로 두고(`~/.ssh/<계정>`), 디렉터리가 계정을 고른다. 기본 키가 agent 에 올라가면 다른 계정 디렉터리에서도 그 키로 인증된다
- overlay 와 dotfiles-private 은 gh 토큰(HTTPS)으로 받는다. 아직 SSH 키가 없기 때문이다. overlay 는 로그인된 계정을 차례로 시험해 받을 수 있는 계정으로 받는다
- 이 레포에는 overlay 의 이름·위치·회사 정보를 적지 않는다. 입력한 값은 레포 밖 `install.env` 에만 저장된다

### install.sh가 하는 일

1. 옵션 결정 (인자 > 저장값 > 질문 > 기본값)
2. Homebrew 설치 (없으면)
3. `brew bundle`로 [Brewfile](Brewfile)의 CLI·앱 설치 (컨테이너 런타임은 고른 것만. 고르지 않은 쪽이 이미 있으면 지우지 않고 경고)
4. [Claude Code](https://claude.com/claude-code) 설치 (없으면, 네이티브 설치기. 자동 업데이트됨)와 [agent-browser](https://github.com/vercel-labs/agent-browser) CLI·브라우저 설치 (npm 전역)
5. 설정 파일을 홈 디렉터리에 심링크 (기존 파일은 `~/.dotfiles-backup/`으로 백업)
6. GitHub: `gh` 로그인, `known_hosts`, SSH 키 준비(`local`: 생성 / `1password`: 공개키 저장 / `work`: 건너뜀) 및 등록
7. `work` 면 overlay 클론 (없을 때만)
8. `../dotfiles-private` 클론 후 그 레포의 `install.sh` 실행 (`work` 면 프로필 work 로, 그 끝에서 overlay 의 `install.sh`)

어느 단계부터 다시 실행해도 된다. 각 단계는 링크를 덮어쓰거나(기존 파일은 백업), 없는 것만 만들거나, 저장된 선택을 다시 쓴다.

머신 전용 파일(`~/.ssh/config.machine`, `~/.gitconfig.machine`)은 install.sh가 만든 것만 고치거나 지운다. 직접 만든 파일은 그대로 두고, `local`이면 키 생성도 건너뛴다.

macOS 기본 설정은 [macos](macos)를 참고한다.

## Structure

| Path | Description |
| --- | --- |
| `Brewfile` | 설치할 CLI·앱 목록. 추가 후 `brew bundle` |
| `zsh/` | `.zshrc`, `.zprofile`, aliases, functions. 프롬프트는 [starship](https://starship.rs) |
| `git/` | `.gitconfig`, `.gitignore_global`. 계정별 설정은 dotfiles-private |
| `vim/` | `~/.vimrc`. vim-plug 와 플러그인 15개(airline·fugitive·signify·fzf·NERDTree·surround·commentary 등)를 처음 열 때 받는다. install.sh 도 미리 받는다. 추가 설정은 `~/.vimrc.local` |
| `ghostty/` | 터미널 설정 (`~/.config/ghostty/config.ghostty`). 한글은 D2Coding |
| `starship/` | 프롬프트 설정 (`~/.config/starship.toml`) |
| `ssh/` | `~/.ssh/config`, `allowed_signers`. 개인 키는 머신마다 `~/.ssh/id_ed25519` (또는 1Password) |
| `hammerspoon/` | 앱 실행·창 관리 단축키 ([README](hammerspoon/README.md)) |
| `macos/` | `defaults` 설정 스크립트와 수동 설정 가이드 |

공개하면 안 되는 설정은 [dotfiles-private](https://github.com/wicksome/dotfiles-private)에 둔다. 이 레포는 `~/.zshrc.local`, `~/.gitconfig.local`, `~/.ssh/config.local`을 불러오는 자리만 둔다.

## Manual

- Orca 는 install.sh 가 GitHub 릴리즈에서, BusyCal 은 Brewfile 이 설치한다. BusyCal 라이선스는 앱을 처음 열 때 등록한다
- 직접 개발 중인 도구는 `~/workspace/wicksome/`에 클론해서 쓴다
  - [quick-mermaid](https://github.com/wicksome/quick-mermaid): 터미널에서 mermaid 미리보기
