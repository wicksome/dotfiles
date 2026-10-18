# 포트를 점유한 프로세스 확인
port() {
  lsof -i :"$1"
}

calc() {
  echo "$*" | bc -l
}

weather() {
  curl -H "Accept-Language: ko" -4 "wttr.in/${1:-성남시}"
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
