" Leader
let mapleader = " "

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
filetype off " required for vundle setup

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'bling/vim-airline'
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'airblade/vim-gitgutter'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'thoughtbot/vim-rspec'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'vim-syntastic/syntastic'
Plugin 'junegunn/fzf.vim'
Plugin 'Chiel92/vim-autoformat'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

colorscheme grb256

" search using fzf
set rtp+=/usr/local/opt/fzf

if has("vms")
  set nobackup " do not keep a backup file, use versions instead
else
  set backup " keep a backup file (restore to previous version)
  set undofile " keep an undo file (undo changes after closing)
endif
set history=100 " keep 100 lines of command line history
set ruler " show the cursor position all the time
set showcmd " display incomplete commands
set incsearch " do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
    au!

    " For all text files set 'textwidth' to 78 characters.
    autocmd FileType text setlocal textwidth=78

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    autocmd BufReadPost *
          \ if line("'\"") >= 1 && line("'\"") <= line("$") |
          \   exe "normal! g`\"" |
          \ endif

  augroup END

else

  set autoindent

endif " has("autocmd")

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use one space, not two, after punctuation.
set nojoinspaces

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif

" show line numbers http://jeffkreeftmeijer.com/2012/relative-line-numbers-in-vim-for-super-fast-movement/
" only show normal line numbers bc relative ones slow down vim a lot
set nu
function! NumberToggle()
  if(&relativenumber == 1)
    set nonu
  else
    set nu
  endif
endfunc

nnoremap <Leader>w :call NumberToggle()<cr>

:au FocusLost * :set number
:au FocusGained * :set relativenumber

set encoding=utf8

" RSpec.vim mappings
let g:rspec_command = "! NO_COVERAGE=1 bundle exec bin/rspec {spec}"
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>a :call RunAllSpecs()<CR>

" use ,, to trigger emmet
let g:user_emmet_leader_key=','


set wildignore+=*/tmp/*,*.so,*.swp,*.zip

" remove trailing spaces when saving
autocmd BufWritePre * %s/\s\+$//e

" remap autocompletion to ctrl space
" inoremap <Nul> <C-n>

" remap quit file to leader q
noremap <leader>q :q<cr>

" remap save file to leader s
nnoremap <leader>s :w<cr>

" align  current paragraph mapped to leader a
noremap <leader>i =ip

" toggle nerdtree with leader b
map <leader>b :NERDTreeToggle<CR>

" toggle tagbar with leader B
map <leader>B :TagbarToggle<CR>

" map leader p to fzt fuzzy search
map <leader>p :Files<CR>

" map leader f to  search in buffer
map <leader>f :BLines<CR>

" map leader o to split vetically
map <leader>o :vsp<CR>

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

  " bind \ (backward slash) to grep shortcut
  command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!

  " map leader F to search
  map <leader>F :Ag<SPACE>
endif

" bind leader k to grep word under cursor
nnoremap <leader>k :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>


" remap Wq to wq (making the typo so often)
command! Wq wq

" map leader os to open schema
map <Leader>os db/schema.rb<cr>

" map leader r to rails routes
map <Leader>r :e config/routes.rb<cr>

" map leader = to auto format
map <Leader>= :Autoformat<cr>

" display all buffers
let g:airline#extensions#tabline#enabled = 1

" map leader h to prev buffer
map <Leader>h :bprev<cr>

" map leader l to next buffer
map <Leader>l :bnext<cr>

" dont use mappings form git gutter plugin
let g:gitgutter_map_keys = 0

" options for tagbar plugin
let g:tagbar_type_ruby = {
      \ 'kinds' : [
      \ 'm:modules',
      \ 'c:classes',
      \ 'd:describes',
      \ 'C:contexts',
      \ 'f:methods',
      \ 'F:singleton methods'
      \ ]
      \ }

" vim syntastic recommended settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = {
      \ "mode": "active",
      \ "passive_filetypes": ["scss", "py"] }
