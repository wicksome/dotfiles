# CLAUDE.md

이 레포는 **PUBLIC** 이다(github.com/wicksome/dotfiles). 커밋한 내용은 지워도 히스토리·포크·캐시에 남는다고 가정한다.

## 값을 어디에 둘지

| 층 | 위치 | 공개 | 둘 것 |
| --- | --- | --- | --- |
| 공개 | 이 레포 | 누구나 | 누구에게 보여도 되는 설정, 비공개 층을 불러오는 자리 |
| 비공개 | `../dotfiles-private` → `~/.zshrc.local`, `~/.gitconfig.local`, `~/.ssh/config.local` | 본인만 | 공개하고 싶지 않은 **설정** (실제 이메일, 회사 계정, 개인 서버 Host) |
| 머신 | `~/.gitconfig.machine`, `~/.ssh/config.machine` (심링크 아님, 레포 밖) | 그 머신만 | 한 머신에만 해당하는 값 |
| 비밀값 | 1Password (`op read`, SSH Agent) | - | 토큰, 비밀번호, 개인 키 |

비밀값은 비공개 레포에도 커밋하지 않는다.

## 설치를 맡았을 때

설치 순서는 이 레포 → `../dotfiles-private` → (업무 맥이면) 업무 overlay 다. 앞 단계가 다음 단계를 부른다. 각 단계는 다시 실행해도 안전하다.

1. 먼저 상태를 읽기 전용 명령으로 확인하고 표로 보여준다. 추측하지 않는다

   | 확인 | 명령 | 기대 |
   | --- | --- | --- |
   | 이전 선택 | `cat ~/.config/dotfiles/install.env ~/.config/dotfiles/private.env` | 있으면 재실행이다. `MACHINE`·`OVERLAY`·`PROFILE` 을 그대로 쓴다 |
   | gh 계정 | `gh auth status` | 개인 계정이 로그인돼 있다. 업무 맥이면 업무 계정도 있다 |
   | 기본 키 | `ls ~/.ssh` | 업무 맥(`MACHINE=work`)에는 `id_ed25519` 가 없어야 한다 |
   | 컨테이너 | `ls -d /Applications/OrbStack.app /Applications/Docker.app` | 업무 맥은 Docker Desktop 이다 (OrbStack 은 회사 업무에 유료 라이선스) |

2. `install.sh` 는 사용자가 **별도 터미널**에서 실행한다. sudo·브라우저 로그인·패스프레이즈 입력이 있다. Claude Code 의 `!` 는 TTY 가 없어 sudo 가 실패한다
   - `./install.sh` 하나다. 처음에 개인/업무를 고른다. 업무면 overlay 레포(`owner/repo`)와 업무 레포 루트를 묻는다 (사용자에게 값을 확인한다. 이 레포에 적지 않는다)
3. 출력의 노란 `==>` 줄을 모두 모아 표로 정리한다. 실패한 단계만 다시 실행한다 (`../dotfiles-private/install.sh`, `<overlay>/install.sh` 는 따로 실행해도 된다)
4. 끝나면 확인한다. "설치했다" 대신 결과를 보여준다

   ```zsh
   ls -l ~/.zshrc ~/.gitconfig ~/.ssh/config ~/.zshrc.local ~/.gitconfig.local ~/.ssh/config.local
   git -C "$(dirname "$PWD")/dotfiles-private" config user.email   # 개인 계정
   ssh -F /dev/null -o IdentityAgent=none -i ~/.ssh/<키> -o IdentitiesOnly=yes -T git@github.com
   ```

업무 overlay 의 설치·검증은 overlay 레포의 CLAUDE.md 를 따른다. 이 레포에는 그 이름·위치를 적지 않는다.

## 설치 완료 보고

설치(또는 재설치)를 마치면 **체크리스트 하나로 상태를 보고한다**. 사용자는 이 보고만 보고 남은 일을 안다.

규칙
- 항목마다 명령을 실제로 실행하고, 그 출력의 핵심 한 줄을 근거 칸에 적는다. 실행하지 않은 항목은 ✅ 로 쓰지 않는다
- 상태는 다섯 가지만 쓴다: ✅ 완료 · ⚠️ 동작하지만 경고 · ❌ 실패 · ⏸ 사람이 할 일 · ❓ 확인 못 함(이유를 적는다)
- 층 순서대로 표를 잇는다: 이 레포 → `../dotfiles-private` CLAUDE.md 의 체크리스트 → (업무 맥이면) overlay 레포 CLAUDE.md 의 체크리스트
- 맨 위에 한 줄 요약(`✅ n · ⚠️ n · ❌ n · ⏸ n · ❓ n`)을, 맨 아래에 ❌·⏸ 항목의 다음 행동을 순서대로 적는다

```
## 설치 상태 (<날짜 KST>, MACHINE=<personal|work>)
✅ 12 · ⚠️ 1 · ❌ 0 · ⏸ 3 · ❓ 0

### 공개 dotfiles
| 상태 | 항목 | 근거 |
| --- | --- | --- |
| ✅ | Homebrew 패키지 | brew bundle check: dependencies are satisfied |
...
### 다음 행동
1. ...
```

이 레포의 항목

| 항목 | 명령 | ✅ 조건 |
| --- | --- | --- |
| 선택값 | `cat ~/.config/dotfiles/install.env` | `MACHINE`·`GITHUB_MODE`·`CONTAINER` 가 있다. work 면 `OVERLAY` 도 있다 |
| Homebrew 패키지 | `brew bundle check --file=<이 레포>/Brewfile` | `dependencies are satisfied` |
| 설정 링크 | `for f in ~/.zshrc ~/.zprofile ~/.gitconfig ~/.gitignore_global ~/.vimrc ~/.ssh/config ~/.ssh/allowed_signers ~/.hammerspoon ~/.config/starship.toml ~/.config/ghostty/config.ghostty; do printf '%s -> %s\n' "$f" "$(readlink "$f")"; done` | 모두 이 레포 안을 가리킨다 |
| Claude Code·agent-browser | `claude --version; agent-browser --version` | 버전이 나온다 |
| vim 플러그인 | `ls ~/.vim/plugged \| wc -l` | 15 이상 |
| Orca | `ls -d /Applications/Orca.app` | 있다 |
| 폰트 | `ls ~/Library/Fonts \| grep -cE 'D2Coding\|JetBrainsMono'` | 1 이상 |
| GitHub 키 | personal: `ssh -T git@github.com` / work: `test ! -e ~/.ssh/id_ed25519 && echo none` | personal: 개인 계정 인사 / work: `none` (계정별 키는 다음 층이 본다) |
| 레포가 깨끗하다 | `git -C <이 레포> status --short` | 출력 없음. 있으면 ⚠️ 다. `ssh/allowed_signers` 에 이 머신 공개키가 더해진 것은 install.sh 가 한 일이라 커밋한다. 그 밖은 다른 설치기가 덧붙인 줄이다 (커밋하지 말고 되돌린다) |
| 다음 층 실행 | `cat ~/.config/dotfiles/private.env` | `PROFILE` 이 `MACHINE` 과 같다 |

## 이 레포에 넣으면 안 되는 것

- 비밀값: API 토큰, 비밀번호, 개인 키, 세션 쿠키, `.env` 내용
- 실제 이메일 주소 (GitHub noreply 주소만 허용)
- 회사·고객 정보: 회사명, 사내 도메인·호스트·URL, 사내 레포·저장소 주소, 업무 계정명
- 네트워크 정보: 개인 서버 IP·호스트명, Wi-Fi 이름, VPN 설정
- 사용자명이 박힌 절대 경로 (`/Users/<name>/...`) → `~` 또는 `$HOME`
- 전화번호, 주소, 기기 시리얼, 라이선스 키
- 위 정보를 담은 주석·예시·커밋 메시지 (커밋 메시지도 공개된다)
- 다른 층의 이름·위치: 업무 overlay 레포 이름·경로, 회사 계정명. 이 레포는 `--overlay=<dir>` 처럼 자리만 둔다

공개해도 되는 것(이미 공개된 것): GitHub 사용자명 `wicksome`, 이름, noreply 이메일, SSH **공개키**(`ssh/allowed_signers`), 1Password 앱 공통 경로.

판단이 애매하면 비공개 층에 두고 이 레포에는 불러오는 자리만 둔다.

## 다른 도구가 추가한 줄

설치기(OrbStack 등)가 `ssh/config`, `zsh/.zprofile` 같은 심링크 대상에 줄을 덧붙이면 이 레포의 작업 트리가 바뀐다. 커밋 전에 `git diff` 로 내용을 보고, 머신 전용이거나 개인 값이면 머신·비공개 층으로 옮긴다.

## 커밋 전 확인

```bash
git diff --cached                     # 올라갈 내용을 직접 읽는다
git grep -nIE '(api[_-]?key|token|secret|passw(or)?d)\s*[:=]|BEGIN [A-Z ]*PRIVATE KEY|/Users/[a-z]|[a-z0-9._%+-]+@[a-z0-9.-]+\.(com|net|io|co\.kr)' \
  -- ':!CLAUDE.md' | grep -vE 'users\.noreply\.github\.com|git@github\.com'
```

두 번째 명령은 아무것도 출력하지 않아야 한다. 출력이 있으면 한 줄씩 보고 위 표에 따라 옮긴다. 정규식 검사는 보조 수단이다. 회사명·호스트명 같은 것은 패턴으로 잡히지 않으니 diff 를 읽어서 확인한다.

이미 커밋·푸시한 비밀값은 히스토리 정리로 끝나지 않는다. 먼저 해당 키·토큰을 폐기(rotate)한다.
