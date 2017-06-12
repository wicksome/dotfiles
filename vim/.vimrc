" .vimrc Config - yeongjun.kim

:let s:darwin = has('mac')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Plugins!
"                            Managed with vim-plug
"                     https://github.com/junegunn/vim-plug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

" Interface
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf',                 { 'dir': '~/.fzf', 'do': 'yes \| ./install' }

" Colors
Plug 'noahfrederick/vim-hemisu'
Plug 'atelierbram/Base2Tone-vim'
Plug 'owickstrom/vim-colors-paramount'

" Edit
Plug 'terryma/vim-multiple-cursors'

function! BuildYCM(info)
  if a:info.status == 'installed' || a:info.force
    !./install.py --clang-completer --gocode-completer
  endif
endfunction
Plug 'valloric/youcompleteme', { 'for': ['c', 'cpp'], 'do': function('BuildYCM') }

" Browsing
Plug 'Yggdroot/indentLine', "{ 'on': 'IndentLinesEnable' }
autocmd! User indentLine doautocmd indentLine Syntax

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
augroup nerd_loader
  autocmd!
  autocmd VimEnter * silent! autocmd! FileExplorer
  autocmd BufEnter,BufNew *
        \  if isdirectory(expand('<amatch>'))
        \|   call plug#load('nerdtree')
        \|   execute 'autocmd! nerd_loader'
        \| endif
augroup END

if v:version >= 703
  "Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle'      }
endif

" Git
"Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
if v:version >= 703
  Plug 'mhinz/vim-signify'
endif

" Lang
Plug 'nsf/gocode',                   { 'tag': 'v.20150303', 'rtp': 'vim' }
Plug 'fatih/vim-go',                 { 'tag': '*' }
Plug 'plasticboy/vim-markdown'
Plug 'rizzatti/dash.vim'
Plug 'jelera/vim-javascript-syntax'

" Lint
Plug 'w0rp/ale', { 'on': 'ALEEnable', 'for': ['ruby', 'sh'] }
"Plug 'scrooloose/syntastic'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                              BASIC SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set number                                                " show absolute line number of the current line
set autoindent smartindent
set shiftwidth=4 tabstop=4 softtabstop=4 
set expandtab smarttab
set laststatus=2                                          " always show status bar
set showcmd
set visualbell
set backspace=indent,eol,start
set encoding=utf-8 fileencodings=utf-8                    " encoding
set nobackup nowritebackup noswapfile                     " no backup or swap
set hlsearch incsearch ignorecase smartcase               " search
set ruler                                                 " show cursor position in status bar
set cursorline
"set nocursorline
set history=500                                           " history size
set showmatch                                             " 자동 괄호맞쳐주기
set title
set showmode	                                          " show current mode
set ai
set t_Co=256
set clipboard=unnamed                                     " copy to clipboard

"highlight LineNr ctermfg=white ctermbg=234

" search options
let g:MultipleSearchMaxColors=8
hi Search0 ctermbg=blue guibg=blue ctermfg=white guifg=white
hi Search1 ctermbg=green guibg=green ctermfg=black guifg=black
hi Search2 ctermbg=magenta guibg=magenta ctermfg=white guifg=white
hi Search3 ctermbg=cyan guibg=cyan ctermfg=black guifg=black
hi Search4 ctermbg=brown guibg=brown ctermfg=white guifg=white
hi Search5 ctermbg=gray guibg=gray ctermfg=black guifg=black
hi Search6 ctermbg=red guibg=red ctermfg=white guifg=white

" Setting cursor, cursor line
if $TERM_PROGRAM =~ "iTerm"
    let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
    let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
    "let &t_ti.="\<Esc>]1337;HighlightCursorLine=true\x7"
    "let &t_te.="\<Esc>]1337;HighlightCursorLine=false\x7"
endif

" For MacVim
set noimd
set imi=1
set ims=-1

" ctags
set tags=./tags;/

" mouse
silent! set ttymouse=xterm2
set mouse=a
set nomousehide                                           " don't hide the mouse cursor while typing
set mousemodel=popup                                      " right-click pops up context menu

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Mappings
" see: http://blog.naver.com/PostView.nhn?blogId=nfwscho&logNo=220407221737
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Save
inoremap <C-s>     <C-O>:update<cr>
nnoremap <C-s>     :update<cr>
nnoremap <leader>s :update<cr>
nnoremap <leader>w :update<cr>

vnoremap <leader><c> "*y

" <F10> | NERD Tree
nnoremap <F10> :NERDTreeToggle<cr>

" <F11> | Tagbar
if v:version >= 703
  inoremap <F11> <esc>:TagbarToggle<cr>
  nnoremap <F11> :TagbarToggle<cr>
  let g:tagbar_sort = 0
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             Plugin Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

syntax enable
set background=dark
"colorscheme hemisu
colorscheme paramount
"colorscheme Base2Tone_EveningDark
hi Normal ctermbg=none " set custom background color

let g:vim_markdown_folding_disabled = 1
let g:airline#extensions#tabline#enabled = 1

let g:airline_powerline_fonts = 1
let g:airline_theme='bubblegum'
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'

" vim-fugitive
nmap     <Leader>g :Gstatus<CR>gg<c-n>
nnoremap <Leader>d :Gdiff<CR>

" NERDTree
let NERDTreeWinPos='left'
noremap <c-\> :NERDTreeToggle<cr>
noremap \nf :NERDTreeFind<cr>

" FZF
nmap <c-p> :FZF<cr>

" vim-test
nmap <silent> <leader>tt :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ts :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>
nmap <silent> <leader>tv :TestVisit<CR>
let g:test#strategy = 'tslime'
let g:test#preserve_screen = 1

" Don't prompt to load ycm_extra_conf.py for YouCompleteMe; just load it.
let g:ycm_confirm_extra_conf = 0
