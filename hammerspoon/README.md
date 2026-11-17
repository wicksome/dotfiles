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
macOS 가 키 이벤트에 붙이는 keyboard type 으로 노트북 키보드와 패드를 구분한다(패드 40).

- 동작 연결: `doio.bind("1", function() ... end)`
- 다른 키로 바꾸기: `doio.remap("1", "f13")` (macOS 는 F20 까지만 있다)

| 패드 입력 | 바꿀 수 있나 |
| --- | --- |
| 키 15개 (`1`~`0`, `up`, `return`, `left`, `down`, `right`) | O |
| 오른쪽 작은 노브 회전 (`knobLeft`, `knobRight`) | O |
| 왼쪽 아래 `MO` 키, 오른쪽 작은 노브 누름 | X. 펌웨어 레이어 키라 맥으로 이벤트를 보내지 않는다 |
| 왼쪽 작은 노브(곡 넘김), 큰 노브(볼륨) | X. 미디어 이벤트는 keyboard type 이 0 이라 노트북 키와 구분할 수 없다 |

`doio.remapMedia` 로 미디어 키도 바꿀 수 있다. 노트북 미디어 키와 구분되지 않아서 `app` 조건을 반드시 건다.

Bluetooth 연결은 1분 쉬면 잠들고, 깨우는 첫 입력은 맥에 전달되지 않는다.
오른쪽 작은 노브를 누르면 레이어가 바뀐다(표시창 1~4). 레이어 1 이 아니면 노브가 아무것도 보내지 않을 수 있다.

### 모든 앱

| 패드 입력 | 동작 |
| --- | --- |
| `9` (3행 1열) | 배치 보기. 앞 앱 기준으로 패드 배치를 그려 10초 보여준다. 다시 누르면 닫는다 (`doio-overlay.lua`) |
| `0` (3행 2열) | macOS 받아쓰기 켜기/끄기. 앞 앱의 「편집 > 받아쓰기 시작…」 메뉴를 실행하고, 메뉴가 없으면 🌐 두 번을 흉내 낸다 (`dictation.lua`) |

배치 보기는 `doio.describe` 로 등록된 매핑을 읽어 그린다. 매핑에 `label` 을 주면 그 이름이 표시된다.

### Orca 모드 (`doio-orca.lua`)

Orca 가 앞에 있을 때만 바뀐다.

| 패드 입력 | 동작 |
| --- | --- |
| `1` (1행 1열) | <kbd>⌘</kbd><kbd>⌥</kbd><kbd>A</kbd> |
| `2` / `3` (1행 2·3열) | <kbd>⌘</kbd><kbd>⇧</kbd><kbd>[</kbd> / <kbd>⌘</kbd><kbd>⇧</kbd><kbd>]</kbd> (이전 / 다음 탭) |
| `4` (1행 4열) | <kbd>⌘</kbd><kbd>⌥</kbd><kbd>T</kbd> |
| 왼쪽 작은 노브 ↺ / ↻ | <kbd>⌘</kbd><kbd>⇧</kbd><kbd>↑</kbd> / <kbd>⌘</kbd><kbd>⇧</kbd><kbd>↓</kbd> |
| 왼쪽 작은 노브 누름 | 아무 동작 안 함 (음악 앱이 켜지지 않게 막음) |
| 오른쪽 작은 노브 ↺ / ↻ | 한 칸에 2줄씩 위 / 아래 휠 스크롤 (마우스 포인터 아래 창) |
| 큰 노브 ↺ / ↻ | <kbd>←</kbd> / <kbd>→</kbd> |
| 큰 노브 누름 | 아무 동작 안 함 (음소거되지 않게 막음) |
| `up` (3행 3열) | <kbd>tab</kbd> |
| `return` (3행 4열) | <kbd>delete</kbd> |
| `left` (4행 2열) | <kbd>⌘</kbd><kbd>E</kbd> (Orca 음성 입력) |
| `down` (4행 3열) | <kbd>space</kbd> (Claude Code 음성 입력, 누르고 있는 동안 유지) |
| `right` (4행 4열) | <kbd>return</kbd> |

Orca 가 앞에 있으면 노트북의 곡 넘김·재생·볼륨·음소거 키도 같은 동작으로 바뀐다.

참고: [DOIO KB16B-02 사용 후기 — 유선 전환·VIA·Bluetooth 제한](https://blog.naver.com/cotton_mellow_s2/223348486592)
