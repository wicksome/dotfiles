# 포트를 점유한 프로세스 확인
port() {
  lsof -i :"$1"
}

calc() {
  echo "$*" | bc -l
}

weather() {
  curl -H "Accept-Language: ko" -4 "wttr.in/$1"
}

http-status() {
  open "https://developer.mozilla.org/ko/docs/Web/HTTP/Status/$1"
}

# 하위 디렉터리의 git 레포에서 브랜치 검색
# usage: git-find-branches <branch> [dir]
git-find-branches() {
  if [[ -z "$1" ]]; then
    echo "usage: git-find-branches <branch> [dir]" >&2
    return 1
  fi

  local branch="$1" dir="${2:-.}" sub b
  for sub in "$dir"/*(/N); do
    [[ -d "$sub/.git" ]] || continue
    for b in ${(f)"$(git -C "$sub" branch --all --format='%(refname:short)' | grep "$branch")"}; do
      print -P "%F{green}${sub:t}%f $b"
    done
  done
}

# 컨테이너 안에서 셸 실행
# usage: dexec <container> [shell]
dexec() {
  docker exec -it "$1" "${2:-/bin/bash}"
}

# epoch(초 10자리·밀리초 13자리)를 UTC·로컬·지정 타임존 시각으로 바꾼다. 인자가 없으면 지금
# usage: epoch [timestamp] [timezone...]   예) epoch 1709122800000 America/New_York Asia/Tokyo
epoch() {
  local input="${1:-$(date +%s)}" secs tz fmt="+%Y-%m-%d %H:%M:%S"
  if [[ ! "$input" =~ ^[0-9]+$ ]]; then
    echo "usage: epoch [timestamp] [timezone...]" >&2
    return 1
  fi
  (( ${#input} > 10 )) && secs=$(( input / 1000 )) || secs=$input
  [[ -z "$1" ]] && echo "$input (seconds)"
  echo "$(TZ=UTC date -j -f %s "$secs" "$fmt") (UTC)"
  echo "$(date -j -f %s "$secs" "$fmt") ($(date +%z))"
  for tz in "${@:2}"; do
    echo "$(TZ=$tz date -j -f %s "$secs" "$fmt") ($tz)"
  done
}
alias e="epoch"
