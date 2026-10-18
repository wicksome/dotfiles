# .files

> These are my dotfiles. Take anything you want, but at your own risk.

Apple Silicon macOS 기준.

## Installation

```bash
mkdir -p ~/workspace/wicksome
cd ~/workspace/wicksome
git clone https://github.com/wicksome/dotfiles
cd dotfiles
./install.sh
```

`install.sh`가 하는 일:

1. Homebrew 설치 (없으면)
2. `brew bundle`로 [Brewfile](Brewfile)의 CLI·앱 설치
3. [Claude Code](https://claude.com/claude-code) 설치 (없으면, 네이티브 설치기. 자동 업데이트됨)
4. 설정 파일을 홈 디렉터리에 심링크 (기존 파일은 `~/.dotfiles-backup/`으로 백업)

macOS 기본 설정은 [macos](macos)를 참고한다.

## Structure

| Path | Description |
| --- | --- |
| `Brewfile` | 설치할 CLI·앱 목록. 추가 후 `brew bundle` |
| `zsh/` | `.zshrc`, `.zprofile`, aliases, functions. 프롬프트는 [starship](https://starship.rs) |
| `git/` | `.gitconfig`, `.gitignore_global`, 계정별 설정 `accounts/` |
| `ssh/` | `~/.ssh/config`. 개인 키는 1Password SSH Agent에 보관 |
| `hammerspoon/` | 앱 실행·창 관리 단축키 ([README](hammerspoon/README.md)) |
| `macos/` | `defaults` 설정 스크립트와 수동 설정 가이드 |

머신별 설정은 `~/.zshrc.local`에 둔다 (git에 올리지 않음).

## Manual

- 직접 설치: Orca, BusyCal
- 직접 개발 중인 도구는 `~/workspace/wicksome/`에 클론해서 쓴다
  - [quick-mermaid](https://github.com/wicksome/quick-mermaid): 터미널에서 mermaid 미리보기
