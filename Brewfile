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

# 사람용 (쉘 편의)
brew "zoxide"                   # autojump 대체 (j)

########################################
# Apps
########################################
cask "font-d2coding"           # Ghostty 한글 폰트
cask "1password"
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

# 이미 직접 설치함: Orca, BusyCal
