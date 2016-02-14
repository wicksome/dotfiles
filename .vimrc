" .vimrc config
" by yeongjun.kim

""""""""""""""""BASE CONFIG""""""""""""""""
set t_Co=256

" 백업파일 정지
set nobackup

" 한글 인코딩
set encoding=utf-8
set fileencodings=utf-8

" 들여쓰기
set autoindent	" 자동 들여쓰기
set cindent	" C 자동 들여쓰기
set smartindent	" 스마트 들여쓰기
set shiftwidth=4" 들여쓰기 여백
" set expandtab " 탭 대신 스페이스 사용

" tab setting
set tabstop=4

" 줄 번호 설정
set number
highlight LineNr ctermfg=white ctermbg=234

" 커서 라인 설정
hi CursorLine cterm=bold term=bold ctermfg=NONE guibg=NONE guifg=NONE
set cursorline

" 구문강조, 테마 사용
syntax on
set background=dark	" 하이라이팅
"colorscheme solarized " vi 테마 설정

" 검색 설정
set hlsearch
let g:MultipleSearchMaxColors=8 
hi Search0 ctermbg=blue guibg=blue ctermfg=white guifg=white 
hi Search1 ctermbg=green guibg=green ctermfg=black guifg=black 
hi Search2 ctermbg=magenta guibg=magenta ctermfg=white guifg=white 
hi Search3 ctermbg=cyan guibg=cyan ctermfg=black guifg=black 
hi Search4 ctermbg=brown guibg=brown ctermfg=white guifg=white 
hi Search5 ctermbg=gray guibg=gray ctermfg=black guifg=black 
hi Search6 ctermbg=red guibg=red ctermfg=white guifg=white

" 화면 표시
set title
set showmode	" 현재 모드 표시
set ruler	" 커서 줄, 칸 위치 표시

" 편집기록 갯수 설정
set history=500

" 잘못 눌렀을 때 화면 깜박이기
set visualbell

"백스페이스 사용
set bs=indent,eol,start 

" 자동 괄호맞쳐주기
set showmatch  " (set sm) 

" 마우스 스크롤 활성
set mouse=nicr

" 80 라인 표시하기
"set colorcolumn=80
":match ErrorMsg '\%>80v.\+'

" 기타
set ai
set showmatch   " 자동 괄호맞춰주기  (set sm) 
set showcmd		" display incomplete commands

" 파일 타입 관련 설정
filetype plugin on
filetype indent on " 파일 종류에 따른 구문강조  
filetype plugin indent on
