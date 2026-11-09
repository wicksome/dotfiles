# Usage: brew bundle --file=~/workspace/wicksome/dotfiles/Brewfile

########################################
# Shell
########################################
brew "starship"                 # prompt
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

########################################
# CLI (사람 + Claude Code가 함께 쓰는 것)
########################################
brew "git"                      # macOS 기본보다 최신
brew "gh"                       # GitHub PR·이슈·API. 웹 페이지 대신 JSON으로 받아 토큰 절약
brew "ripgrep"                  # 빠른 검색, .gitignore 존중
brew "jq"                       # JSON 출력에서 필요한 필드만 추출
brew "node"                     # npm 전역 CLI용 (agent-browser)

brew "shellcheck"               # 셸 스크립트 검사 (이 레포 스크립트를 고칠 때)
brew "graphviz"                 # PlantUML 렌더링 (VS Code PlantUML 확장이 dot 을 쓴다)
brew "mas"                      # App Store 앱 설치 (Amphetamine 은 install.sh 가 설치한다)

# 사람용 (쉘 편의)
brew "zoxide"                   # autojump 대체 (j)
brew "tree"                     # 디렉터리 구조 보기
brew "mole"                     # 맥 정리 (캐시·디스크)

########################################
# Apps
########################################
cask "font-d2coding"           # Ghostty 한글 폰트
cask "font-jetbrains-mono"      # 코딩 폰트 (IDE·VS Code. Ghostty 는 내장본을 쓴다)
cask "1password"
cask "1password-cli"             # op. 비밀값은 쓸 때 op read 로 읽는다
cask "claude"                   # Claude 데스크톱 앱 (Claude Code CLI는 install.sh가 설치)
cask "ghostty"                  # terminal
cask "hammerspoon"
cask "obsidian"
cask "visual-studio-code"       # 뷰어/가벼운 편집용
cask "clipy"                    # clipboard
cask "hiddenbar"                # menu bar 정리
cask "reminders-menubar"
# 컨테이너 런타임: install.sh --container=orbstack|docker|none (기본 orbstack)
container = ENV.fetch("HOMEBREW_DOTFILES_CONTAINER", "orbstack")
cask "orbstack" if container == "orbstack"
cask "docker-desktop" if container == "docker"
cask "stats"                    # menu bar 시스템 모니터
cask "appcleaner"               # 앱 삭제 시 남는 파일까지
tap "chattymin/tap", trusted: true
cask "poke-token-bar"           # AI 토큰 사용량으로 포켓몬을 키우는 menu bar 앱 (데이터는 별도로 옮긴다)
cask "busycal"                  # 캘린더 (라이선스는 앱에서 등록)
tap "wicksome/tap", trusted: true
cask "wicksome/tap/quick-mermaid"  # Mermaid·PlantUML 미리보기와 qmmd CLI (Claude Code 가 그림마다 qmmd --link 로 링크를 붙인다)

# Orca 는 cask 가 없어 install.sh 가 GitHub 릴리즈에서 받는다 (Homebrew 의 "orca" 는 다른 앱이다)
