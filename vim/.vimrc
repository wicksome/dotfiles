set nocompatible   " -u 로 직접 읽어도 줄 이음(\)을 쓸 수 있게 한다
" 플러그인은 vim-plug 로 관리한다. 처음 열 때 vim-plug 와 플러그인을 받는다 (install.sh 도 미리 받는다)
" 개인·머신별 추가 설정은 ~/.vimrc.local 에 둔다

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:plug_vim = expand('~/.vim/autoload/plug.vim')
if empty(glob(s:plug_vim))
  silent execute '!curl -fsLo ' . shellescape(s:plug_vim) . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/plugged')
" 화면
Plug 'owickstrom/vim-colors-paramount'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/vim-indent-guides'
" 편집
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'              " gcc 주석 토글
Plug 'junegunn/vim-easy-align'
Plug 'jiangmiao/auto-pairs'
" 파일·검색
Plug 'preservim/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }   " fzf 바이너리를 플러그인 폴더에 받는다 (brew 설치 불필요)
Plug 'junegunn/fzf.vim'
" git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'                 " :GBrowse 로 GitHub 열기
Plug 'mhinz/vim-signify'                 " 변경 줄 표시
" 문법
Plug 'preservim/vim-markdown'
call plug#end()

" 받지 않은 플러그인이 있으면 처음 열 때 받는다
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | source $MYVIMRC
  \| endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf-8 fileencodings=utf-8,cp949,euc-kr       " 한글 파일(cp949·euc-kr)도 연다
set number ruler cursorline showcmd showmode showmatch title
set laststatus=2                                          " 상태줄 항상 표시
set autoindent smartindent
set shiftwidth=4 tabstop=4 softtabstop=4 expandtab smarttab
set backspace=indent,eol,start
set nobackup nowritebackup noswapfile
set hlsearch incsearch ignorecase smartcase
set history=500
set clipboard=unnamed                                     " 시스템 클립보드
set mouse=a nomousehide
set noimd imi=1 ims=-1                                    " 입력 모드를 벗어나면 영문으로
set tags=./tags;/
syntax enable
set background=dark
silent! colorscheme paramount
hi Normal ctermbg=none                                    " 터미널 배경을 그대로 쓴다

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 저장
inoremap <C-s> <C-O>:update<cr>
nnoremap <C-s> :update<cr>
nnoremap <leader>s :update<cr>
nnoremap <leader>w :update<cr>
" 지우기는 레지스터에 남기지 않는다 (붙여넣을 내용을 덮지 않게)
nnoremap x "_x
nnoremap d "_d
vnoremap d "_d
vnoremap <leader>c "*y

" NERDTree
let NERDTreeWinPos = 'left'
let NERDTreeShowHidden = 1
noremap <c-\> :NERDTreeToggle<cr>
noremap \nf :NERDTreeFind<cr>

" fzf
nnoremap <c-p> :Files<cr>

" easy-align (vipga, gaip)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" fugitive
nnoremap <leader>g :Git<cr>
nnoremap <leader>d :Gdiffsplit<cr>

" airline
let g:airline_powerline_fonts = 1
let g:airline_theme = 'bubblegum'
let g:airline#extensions#tabline#enabled = 1

" indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
