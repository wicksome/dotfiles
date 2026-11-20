# Hammerspoon

`install.sh`가 `~/.hammerspoon`으로 심링크한다.

## Launch Apps

<kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>⌃</kbd> + key: 앱 실행, 이미 앞에 있으면 숨기기

| Key | Application |
| --- | --- |
| <kbd>,</kbd> | System Settings |

## Window Management

<kbd>⌃</kbd> + <kbd>⌥</kbd> + key

| Key | Action |
| --- | --- |
| <kbd>enter</kbd> | Maximize |
| <kbd>delete</kbd> | Undo (snapback) |
| <kbd>c</kbd> | Move to center |
| <kbd>m</kbd> | Center at 75% size |
| <kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> | Half left / down / up / right |
| <kbd>←</kbd> <kbd>↓</kbd> <kbd>↑</kbd> <kbd>→</kbd> | Move window |
| <kbd>-</kbd> <kbd>=</kbd> | Size down / up |
| <kbd>q</kbd> <kbd>s</kbd> | Height down / up |
| <kbd>a</kbd> <kbd>w</kbd> | Width down / up |
| <kbd>n</kbd> | Send to next monitor |
| <kbd>1</kbd> ~ <kbd>6</kbd> | Move to grid slot |
| <kbd>`</kbd> | Toggle grid mode |
| <kbd>Tab</kbd> | Mission Control |

## Mouse (BetterSnapTool 대체)

클릭 없이 수정키를 누른 채 마우스를 움직인다.

| Key | Action |
| --- | --- |
| <kbd>⌘</kbd> + <kbd>⇧</kbd> + 마우스 이동 | 마우스 아래 창 이동 |
| <kbd>⌘</kbd> + <kbd>⌃</kbd> + 마우스 이동 | 크기 조절 (오른쪽→넓게, 아래→길게. 왼쪽 위는 고정) |
| 마우스 6번째 버튼 | Mission Control |

## DOIO KB16B-02 매크로 패드

`doio.lua` 가 패드 입력만 가로채 동작이나 다른 키로 바꾼다.
키 이벤트를 보낸 기기로 다른 키보드와 패드를 구분한다. 키 이벤트의 87번 값은 그 키를 보낸 HID 서비스의 IORegistry ID 다(Apple 공개 문서에는 없는 값).
`doio.lua` 는 처음 보는 ID 를 `ioreg` 로 한 번 찾아, 제조사·제품 ID 가 패드(Bluetooth 6421/61166, USB 65261/24672)면 패드 입력으로 본다.
ID 는 다시 연결할 때마다 바뀌므로 고정값으로 적지 않는다. DOIO Studio 사이드바 「인식 정보」에 최근 키를 보낸 기기와 ID 가 나온다.

87번 값을 못 얻으면 예전 방식대로 keyboard type 41 을 패드로 본다. 그래서 keyboard type 은 등록하지 않아도 된다(기본값 40).
예전에 패드를 41 로 등록했다면 아래 명령으로 기본값 40 으로 되돌릴 수 있다. 되돌린 뒤 패드를 다시 연결한다.

```zsh
sudo defaults write /Library/Preferences/com.apple.keyboardtype keyboardtype -dict-add "61166-6421-0" -int 40 "24672-65261-0" -int 40
```

패드의 어느 자리가 어떤 키를 보내는지는 펌웨어 키맵이 정한다. `doio-firmware.json` 은 그 키맵을 자리별로 옮겨 적은 파일이고, `doio.lua` 는 이 파일로 패드 자리를 알아본다.
DOIO Studio 가 USB 로 키맵을 읽거나 쓸 때마다 갱신한다. 파일이 없으면 펌웨어 기본 키맵으로 본다.

### DOIO Studio (설정 페이지)

Hammerspoon 이 `http://localhost:17816/` 에 설정 페이지를 띄운다(`doio-studio.lua`, `doio-studio/`). WebHID 를 쓰므로 Chrome 으로 연다.

```zsh
hs -c 'require("doio-studio").open()'
```

메뉴는 「키맵」과 「매크로」 둘이다. 키맵 안의 「펌웨어」 탭이 바닥이고, 「앱별 매핑」 탭은 그 위에 덮는 Hammerspoon 규칙이다. 두 탭은 고른 칸을 함께 기억한다.

| 화면 | 하는 일 | 연결 |
| --- | --- | --- |
| 키맵 › 펌웨어 | 레이어별 키맵 읽기·쓰기, 백업·복원, 키 눌림 보기 | USB 만 (VIA 프로토콜) |
| 매크로 | M0~M15 편집, 패드 저장 공간(355 바이트) 표시 | USB 만 |
| 키맵 › 앱별 매핑 | `doio-mapping.json` 편집. 레이어는 구분하지 못하고 펌웨어 레이어 0 이 보내는 키를 덮는다. 저장하면 같은 검사(`mapping.validate`)를 거쳐 Hammerspoon 을 다시 읽는다 | USB·Bluetooth |

사이드바에서 패드 연결 방식(USB·Bluetooth)을 본다. 「인식 정보」를 펼치면 최근 키를 보낸 기기의 87번 값과 keyboard type 이 나온다.
Bluetooth 로 연결돼 있으면 패드 배터리(%)와 충전 이후 사용량도 보인다. 값은 `system_profiler` 에서 읽고, 바뀔 때마다 `~/Library/Caches/doio-battery.json` 에 기록한다(10분마다 확인).
앱별 매핑 칸은 Hammerspoon 이 덮어쓴 동작이고, 규칙이 있는 칸 오른쪽 위에 원래 펌웨어 키가 나온다. 펌웨어 키맵 탭은 패드에 저장된 값만 보여준다.
서버는 localhost 에서만 받고, 쓰기 요청에는 `X-DOIO-Studio` 헤더를 요구해 다른 웹 페이지가 매핑을 덮어쓰지 못하게 한다.

매핑은 `~/.config/doio/doio-mapping.json` 의 `rules` 에 적는다. 개인 설정이라 이 레포에 두지 않고 비공개 dotfiles 가 이 위치로 링크한다. 파일이 없으면 규칙 없이 시작하고, DOIO Studio 에서 저장하면 만들어진다.
규칙 하나는 입력 하나와 할 일 하나다.

| 필드 | 뜻 |
| --- | --- |
| `key` / `media` | 패드 자리 이름 (아래 표) / 미디어 키 이름 (`PLAY`, `NEXT`, `PREVIOUS`, `MUTE`, `SOUND_UP`, `SOUND_DOWN`) |
| `app` | 이 번들 ID 앱이 앞에 있을 때만 적용한다. 없으면 모든 앱 |
| `block` | `true` 면 아무 동작도 하지 않게 막는다 |
| `send` | 다른 키로 바꾼다. `{ "key": "a", "mods": ["cmd"] }` (macOS 는 F20 까지만 있다) |
| `action` + `params` | `doio-actions.lua` 의 동작을 실행한다 (`openApp`, `dictation`, `layoutOverlay`, `scroll`) |
| `shortcut` / `description` | 배치 보기 화면의 윗줄 / 아랫줄 |

`block`·`send`·`action` 중 정확히 하나만 쓴다. 잘못 적으면 알림이 뜨고, 콘솔에 문제가 있는 규칙 번호가 모두 나온다(`mapping.validate`).
Lua 에서 직접 연결하려면 `doio.bind`·`doio.remap` 을 쓴다.

| 자리 | 이름 |
| --- | --- |
| 키 16개 (왼쪽 위부터 행 순서) | `1` `2` `3` `4` / `5` `6` `7` `8` / `9` `0` `up` `return` / `bottomLeft` `left` `down` `right` |
| 왼쪽 작은 노브 ↺ · 누름 · ↻ | `leftKnobLeft` `leftKnobPress` `leftKnobRight` |
| 큰 노브 ↺ · 누름 · ↻ | `bigKnobLeft` `bigKnobPress` `bigKnobRight` |
| 오른쪽 작은 노브 ↺ · 누름 · ↻ | `knobLeft` `rightKnobPress` `knobRight` |

`key` 규칙은 그 자리가 펌웨어에서 일반 키를 보낼 때만 동작한다. 기본 키맵에서는 아래와 같다.

| 패드 입력 | 바꿀 수 있나 |
| --- | --- |
| 키 15개 (`1`~`0`, `up`, `return`, `left`, `down`, `right`) | O |
| 오른쪽 작은 노브 회전 (`knobLeft`, `knobRight`) | O |
| 왼쪽 아래 `bottomLeft`(MO3), 오른쪽 작은 노브 누름 | X. 펌웨어 레이어 키라 맥으로 이벤트를 보내지 않는다 |
| 왼쪽 작은 노브(곡 넘김), 큰 노브(볼륨) | X. 미디어 이벤트는 keyboard type 이 0 이라 노트북 키와 구분할 수 없다. `media` 규칙을 쓴다 |

펌웨어에서 자리를 레이어·미디어·매크로 키로 바꾸면 그 자리의 `key` 규칙은 건너뛰고 콘솔에 남긴다. 반대로 일반 키로 바꾸면 규칙이 동작한다.

`doio.remapMedia` 로 미디어 키도 바꿀 수 있다. 노트북 미디어 키와 구분되지 않아서 `app` 조건을 반드시 건다.

Bluetooth 연결은 1분 쉬면 잠들고, 깨우는 첫 입력은 맥에 전달되지 않는다.
오른쪽 작은 노브를 누르면 레이어가 바뀐다(표시창 1~4). 키는 레이어 1~3 에서 같은 값을 보내 어느 레이어에서든 매핑이 동작하지만, Hammerspoon 은 같은 이유로 지금 레이어를 알 수 없다. 노브는 레이어 1 이 아니면 아무것도 보내지 않을 수 있으니 표시창을 1 로 둔다.

### 동작

실제 매핑(어느 자리가 무엇을 하는지)은 개인 설정이라 비공개 dotfiles 의 `hammerspoon/README.md` 에 둔다. 여기에는 동작 방식만 적는다.

- 앱 열기(`openApp`): 다른 앱에서 누르면 그 앱으로 간다. 그 앱에서 다시 누르면 넘어오기 전 창으로 돌아간다
- 패드 배치 보기(`layoutOverlay`): 앞 앱 기준으로 그린다. 길게 누르면 누르는 동안만, 짧게 누르면 10초 보여준다. 보이는 중에 누르면 닫는다. 펌웨어 키맵을 바닥으로 두고 Hammerspoon 매핑을 덮어 그린다. 칸 왼쪽 위에 자리 번호(키 #1~#16, 노브 버튼 #17~#25)를 적는다 (`doio-overlay.lua`)
- Mac 받아쓰기(`dictation`): 앞 앱의 「편집 > 받아쓰기 시작…」 메뉴를 실행하고, 메뉴가 없으면 🌐 두 번을 흉내 낸다
- 배치 보기의 칸: 모든 앱 공통 키는 윗줄에 보내는 키(`shortcut`), 아랫줄에 설명(`description`)을 표시한다. 앱 전용 키는 설명을 윗줄, 보내는 키를 아랫줄에 표시한다

참고: [DOIO KB16B-02 사용 후기 — 유선 전환·VIA·Bluetooth 제한](https://blog.naver.com/cotton_mellow_s2/223348486592)
