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

## 이 레포에 넣으면 안 되는 것

- 비밀값: API 토큰, 비밀번호, 개인 키, 세션 쿠키, `.env` 내용
- 실제 이메일 주소 (GitHub noreply 주소만 허용)
- 회사·고객 정보: 회사명, 사내 도메인·호스트·URL, 사내 레포·저장소 주소, 업무 계정명
- 네트워크 정보: 개인 서버 IP·호스트명, Wi-Fi 이름, VPN 설정
- 사용자명이 박힌 절대 경로 (`/Users/<name>/...`) → `~` 또는 `$HOME`
- 전화번호, 주소, 기기 시리얼, 라이선스 키
- 위 정보를 담은 주석·예시·커밋 메시지 (커밋 메시지도 공개된다)

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
