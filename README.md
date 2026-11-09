# .files

> These are my dotfiles. Take anything you want, but at your own risk.

Apple Silicon 맥을 한 번에 같은 환경으로 맞춘다. 개인 맥과 업무 맥 모두 이 레포에서 시작한다.

```bash
git clone https://github.com/wicksome/dotfiles ~/workspace/wicksome/dotfiles
~/workspace/wicksome/dotfiles/install.sh   # 옵션: --help
```

설치·검증 절차와 값을 둘 위치는 [CLAUDE.md](CLAUDE.md)에 있다.

## 기능

| 경로 | 하는 일 |
| --- | --- |
| `install.sh` | Homebrew·앱 설치, 설정 심링크, GitHub SSH 키, [dotfiles-private](https://github.com/wicksome/dotfiles-private)·업무 overlay 연결. 여러 번 실행해도 안전하다 |
| `Brewfile` | CLI·앱 목록 |
| `zsh/` | 셸 설정 |
| `starship/` | 프롬프트 설정 |
| `git/` | 공통 git 설정, SSH 커밋 서명 |
| `ssh/` | SSH 설정, 서명 검증용 공개키(`allowed_signers`) |
| `vim/` | vim 설정과 플러그인 |
| `ghostty/` | 터미널 설정. 한글은 D2Coding |
| `hammerspoon/` | 앱 실행·창 관리 단축키 ([README](hammerspoon/README.md)) |
| `macos/` | 키보드·Dock·Finder 기본값 ([README](macos/README.md)). 직접 실행한다 |

공개하면 안 되는 설정은 dotfiles-private 에 두고, 이 레포는 그 파일을 불러오는 자리만 둔다.
