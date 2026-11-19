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

`doio.lua` 가 패드 입력만 가로채 동작이나 다른 키로 바꾼다. 패드 키맵은 바꾸지 않는다.
macOS 가 키 이벤트에 붙이는 keyboard type 으로 다른 키보드와 패드를 구분한다.
패드의 기본값 40 은 HHKB 같은 외장 키보드와 겹치므로, 맥마다 한 번 패드만 41(ISO)로 등록한다.
패드에는 ISO 와 ANSI 가 다른 키가 없어 입력은 바뀌지 않는다. 등록 후 패드를 다시 연결한다.

```zsh
sudo defaults write /Library/Preferences/com.apple.keyboardtype keyboardtype -dict-add "61166-6421-0" -int 41
```

매핑은 `doio-mapping.json` 의 `rules` 에 적는다. 규칙 하나는 입력 하나와 할 일 하나다.

| 필드 | 뜻 |
| --- | --- |
| `key` / `media` | 패드 키 이름 / 미디어 키 이름 (`PLAY`, `NEXT`, `PREVIOUS`, `MUTE`, `SOUND_UP`, `SOUND_DOWN`) |
| `app` | 이 번들 ID 앱이 앞에 있을 때만 적용한다. 없으면 모든 앱 |
| `block` | `true` 면 아무 동작도 하지 않게 막는다 |
| `send` | 다른 키로 바꾼다. `{ "key": "a", "mods": ["cmd"] }` (macOS 는 F20 까지만 있다) |
| `action` + `params` | `doio-actions.lua` 의 동작을 실행한다 (`openApp`, `dictation`, `layoutOverlay`, `scroll`) |
| `shortcut` / `description` | 배치 보기 화면의 윗줄 / 아랫줄 |

`block`·`send`·`action` 중 정확히 하나만 쓴다. 잘못 적으면 Hammerspoon 콘솔에 규칙 번호와 함께 오류가 난다.
Lua 에서 직접 연결하려면 `doio.bind`·`doio.remap` 을 쓴다.

| 패드 입력 | 바꿀 수 있나 |
| --- | --- |
| 키 15개 (`1`~`0`, `up`, `return`, `left`, `down`, `right`) | O |
| 오른쪽 작은 노브 회전 (`knobLeft`, `knobRight`) | O |
| 왼쪽 아래 `MO` 키, 오른쪽 작은 노브 누름 | X. 펌웨어 레이어 키라 맥으로 이벤트를 보내지 않는다 |
| 왼쪽 작은 노브(곡 넘김), 큰 노브(볼륨) | X. 미디어 이벤트는 keyboard type 이 0 이라 노트북 키와 구분할 수 없다 |

`doio.remapMedia` 로 미디어 키도 바꿀 수 있다. 노트북 미디어 키와 구분되지 않아서 `app` 조건을 반드시 건다.

Bluetooth 연결은 1분 쉬면 잠들고, 깨우는 첫 입력은 맥에 전달되지 않는다.
오른쪽 작은 노브를 누르면 레이어가 바뀐다(표시창 1~4). 키는 레이어 1~3 에서 같은 값을 보내 어느 레이어에서든 매핑이 동작하지만, Hammerspoon 은 같은 이유로 지금 레이어를 알 수 없다. 노브는 레이어 1 이 아니면 아무것도 보내지 않을 수 있으니 표시창을 1 로 둔다.

### 모든 앱

1행의 1·4번과 3·4행 키는 모든 앱에서 아래처럼 바뀐다. `app` 이 있는 규칙이 같은 키를 다시 매핑하면 그 앱에서는 앱별 매핑이 우선한다.

| 패드 입력 | 동작 |
| --- | --- |
| `1` (1행 1열) | Orca 열기. 켜져 있으면 창을 앞으로 가져오고(「Orca로 이동」 알림), 꺼져 있으면 실행한다(「Orca 실행」 알림). 1행 1~3 은 앱 열기 자리다 |
| `4` (1행 4열) | 패드 배치 보기. 앞 앱 기준으로 그린다. 길게 누르면 누르는 동안만, 짧게 누르면 10초 보여준다. 보이는 중에 누르면 닫는다. 칸 왼쪽 위에 위치 번호(키 1~16, 노브 17~19)를 적는다 (`doio-overlay.lua`) |
| `9` (3행 1열) | <kbd>esc</kbd> |
| `0` (3행 2열) | Mac 받아쓰기 켜기/끄기 (`dictation.lua`) |
| `up` (3행 3열) | <kbd>tab</kbd> |
| `return` (3행 4열) | <kbd>delete</kbd> |
| `left` (4행 2열) | Mac 받아쓰기 켜기/끄기 |
| `down` (4행 3열) | <kbd>space</kbd> (Claude 음성 입력, 누르고 있는 동안 유지) |
| `right` (4행 4열) | <kbd>return</kbd> |
| 왼쪽 작은 노브 누름 | 아무 동작 안 함. 누를 때마다 Apple Music 이 켜져서 막았다. 미디어 키라 노트북 재생 키도 함께 막힌다 |

Mac 받아쓰기는 앞 앱의 「편집 > 받아쓰기 시작…」 메뉴를 실행하고, 메뉴가 없으면 🌐 두 번을 흉내 낸다.

배치 보기는 `doio.describe` 로 등록된 매핑을 읽어 그린다. 모든 앱 공통 키는 윗줄에 보내는 키(`shortcut`), 아랫줄에 설명(`description`)을 표시한다. 앱 전용 키(`app` 조건이 있는 매핑)는 하는 일이 주된 정보라 설명을 윗줄, 보내는 키를 아랫줄에 표시한다. 둘 다 매핑 옵션으로 줄 수 있고, `remap` 은 윗줄을 키 조합에서 만든다.

### Orca 모드 (`app`: `com.stablyai.orca`)

Orca 가 앞에 있을 때만 바뀐다. 표에 없는 키는 위 기본 동작을 따른다.

| 패드 입력 | 동작 |
| --- | --- |
| `1` `2` `3` `8` | 아무 동작 안 함 (숫자가 입력되지 않게 막음. 1번의 기본값 Orca 열기도 쓰지 않는다) |
| `5` (2행 1열) | <kbd>⌘</kbd><kbd>⌥</kbd><kbd>A</kbd> (플로팅 토글) |
| `6` / `7` (2행 2·3열) | <kbd>⌘</kbd><kbd>⇧</kbd><kbd>[</kbd> / <kbd>⌘</kbd><kbd>⇧</kbd><kbd>]</kbd> (이전 / 다음 탭) |
| `left` (4행 2열) | <kbd>⌘</kbd><kbd>E</kbd> (Orca 음성 입력) |
| 왼쪽 작은 노브 ↺ / ↻ | <kbd>⌘</kbd><kbd>⇧</kbd><kbd>↑</kbd> / <kbd>⌘</kbd><kbd>⇧</kbd><kbd>↓</kbd> (왼쪽 목록에서 이전 / 다음 워크스페이스) |
| 오른쪽 작은 노브 ↺ / ↻ | 한 칸에 1줄씩 위 / 아래 휠 스크롤 (마우스 포인터 아래 창) |
| 큰 노브 ↺ / ↻ | <kbd>←</kbd> / <kbd>→</kbd> |
| 큰 노브 누름 | 아무 동작 안 함 (음소거되지 않게 막음) |

Orca 가 앞에 있으면 노트북의 곡 넘김·재생·볼륨·음소거 키도 같은 동작으로 바뀐다.

### Aside 브라우저 (`app`: `at.studio.AsideBrowser`)

| 패드 입력 | 동작 |
| --- | --- |
| 오른쪽 작은 노브 ↺ / ↻ | 한 칸에 3줄씩 위 / 아래 휠 스크롤 (마우스 포인터 아래 창) |
| 큰 노브 ↺ / ↻ | <kbd>←</kbd> / <kbd>→</kbd> (Aside 가 앞에 있으면 노트북 볼륨 키도 방향키가 된다) |

참고: [DOIO KB16B-02 사용 후기 — 유선 전환·VIA·Bluetooth 제한](https://blog.naver.com/cotton_mellow_s2/223348486592)
