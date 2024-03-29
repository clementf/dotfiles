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

Plugin 'itchyny/lightline.vim'
Plugin 'mengelbrecht/lightline-bufferline'
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-dispatch'
Plugin 'airblade/vim-gitgutter'
Plugin 'thoughtbot/vim-rspec'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'majutsushi/tagbar'
Plugin 'w0rp/ale'
Plugin 'chr4/nginx.vim'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'rhysd/vim-crystal'
Plugin 'posva/vim-vue'
Plugin 'joker1007/vim-ruby-heredoc-syntax'
Plugin 'christoomey/vim-system-copy'
Plugin 'farmergreg/vim-lastplace'
Plugin 'ngmy/vim-rubocop'
Plugin 'int3/vim-extradite'
Plugin 'AndrewRadev/switch.vim'
Plugin 'tpope/vim-unimpaired'
Plugin 'vimwiki/vimwiki'
Plugin 'elixir-editors/vim-elixir'
Plugin 'elmcast/elm-vim'
Plugin 'isRuslan/vim-es6'
Plugin 'wuelnerdotexe/vim-astro'
Plugin 'leafOfTree/vim-svelte-plugin'
Plugin 'mbbill/undotree'
Plugin 'arcticicestudio/nord-vim'
Plugin 'jacoborus/tender.vim'
Plugin 'jkramer/vim-checkbox'

Plugin 'mg979/vim-visual-multi', {'branch': 'master'}

Plugin 'neoclide/coc.nvim'

Plugin 'ConradIrwin/vim-bracketed-paste'
Plugin 'chrisbra/csv.vim'
Plugin 'noprompt/vim-yardoc'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'jiangmiao/auto-pairs'
Plugin 'leafgarland/typescript-vim'
Plugin 'martinda/Jenkinsfile-vim-syntax'
Plugin 'qpkorr/vim-bufkill'

" snippet mgmt
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
let g:snipMate = { 'snippet_version' : 1 }

" js plugins
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" search using fzf
set rtp+=/opt/homebrew/bin/fzf

if has("vms")
  set nobackup " do not keep a backup file, use versions instead
else
  set backup " keep a backup file (restore to previous version)
  set undofile " keep an undo file (undo changes after closing)
  set directory=~/.vim/tmp
  set backupdir=~/.vim/tmp
  set undodir=~/.vim/tmp
endif

set history=100 " keep 100 lines of command line history
set ruler " show the cursor position all the time
set showcmd " display incomplete commands
set incsearch " do incremental searching
set regexpengine=1 " avoid slow scrolling issue with vim ruby (https://github.com/vim-ruby/vim-ruby/issues/243)

" Line Numbers with relativenumber and number set, shows relative number but has current number on current line.
set relativenumber
set number
set numberwidth=3

" from https://vimtricks.com/p/vim-search-ignore-case/
set ignorecase " Makes pattern matching case-insensitive
set smartcase " Overrides ignorecase if your pattern contains mixed case

:au FocusLost * :set number
:au FocusGained * :set relativenumber

:colo tender
set encoding=utf8

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
endif

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif

set autoindent
set copyindent " copy previous indentation on autoindenting
set showmatch " show matching parenthesis

" Don't show `-- INSERT --` below the statusbar since it's in the statusbar
set noshowmode

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab
set ttyfast
set lazyredraw  " prevent redraws while executing

set hidden " no need to save before changing buffer

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use one space, not two, after punctuation.
set nojoinspaces

" Tab completion
set wildmode=list:longest,list:full

imap <C-J> <Plug>snipMateNextOrTrigger
smap <C-J> <Plug>snipMateNextOrTrigger

" Per-directory .vimrc files
set exrc
set secure

" Switch between the last two files
nnoremap <leader><leader> <c-^>

nnoremap <leader>wo :e .work<cr>

map <silent> <leader>ch :call checkbox#ToggleCB()<cr>

" press return to temporarily get out of the highlighted search
nnoremap <C-n> :nohlsearch<CR><CR>
set hlsearch

" use C-y for vim multi cursor
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<C-y>' " replace C-n
let g:VM_maps['Find Subword Under'] = '<C-y>' " replace C-n

" Don't use Ex mode, use Q for formatting
map Q gq
map <Leader>T :Dispatch bundle exec ruby %<CR>

let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

" RSpec.vim mappings
let g:rspec_command = ":Dispatch bundle exec rspec {spec}"
map <Leader>t :call RunCurrentSpecFile()<CR>

" use ,, to trigger emmet
let g:user_emmet_leader_key=','

set wildignore+=*/tmp/*,*.so,*.swp,*.zip

" remove trailing spaces when saving
autocmd BufWritePre * %s/\s\+$//e

noremap <leader>q :q<cr>
nnoremap <leader>s :w<cr>

" align  current paragraph mapped to leader i
" map leader p to fzt fuzzy search
map <leader>p :Files<CR>
" map leader f to  search in buffer
map <leader>f :BLines<CR>
" map leader o to split vetically
map <leader>o :vsp<CR>
map <leader>b :NERDTreeToggle<CR>
map <leader>C :NERDTreeFind<CR>
map <leader>B :TagbarToggle<CR>

" map leader F to search
map <leader>F :Ag<SPACE>

map <leader>H :History<CR>

" bind leader k to grep word under cursor
nnoremap <leader>k :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
nnoremap <leader>K :call fzf#vim#tags(expand('<cword>'))<CR>

" Coc autocomplete
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" remap Wq to wq (making the typo so often)
command! Wq wq

map <Leader>r :RuboCop<cr>
map <Leader>ra :RuboCop -a<cr>

" status and tab line
let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'gitbranch'], ['readonly', 'filename', 'modified' ] ],
      \   'right': [[ 'lineinfo' ],[ 'percent' ] ]
      \ },
      \ 'tabline': {
      \   'left': [ ['buffers'] ],
      \   'right': [ ],
      \ },
      \ 'component_expand': {
      \   'buffers': 'lightline#bufferline#buffers'
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ 'component_type': {
      \   'buffers': 'tabsel'
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
      \ }

set showtabline=2
let g:lightline.colorscheme = 'darcula'
let g:lightline#bufferline#show_number = 2

" fast navigation between buffers
nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)

map <Leader>m :Emodel<cr>
map <Leader>c :Econtroller<cr>
map <Leader>u :Eunittest<cr>
map <Leader>v :Eview<cr>

map <Leader>x :BD<cr>
map <Leader>d :call delete(expand('%'))<cr>

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=number
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" dont use mappings form git gutter plugin
let g:gitgutter_map_keys = 0

" ingore whitespace with diffs
let g:gitgutter_diff_args = '-w'

" mapping to tig (integrates git in vim)
map <Leader>g1 :Commits<CR>
map <Leader>g2 :Git<CR>
map <Leader>g3 :!git diff -w<CR>
map <Leader>g4 :!git add .<CR><CR>
map <Leader>g5 :!git commit<CR>
map <Leader>g6 :Extradite<CR>
map <Leader>gb :Git blame<CR>

map <Leader>X :%bd<CR>

map <Leader>de o(require('pry'); binding.pry)<ESC>

" map leader h to prev buffer
map <Leader>h :bprev<cr>

" map leader l to next buffer
map <Leader>l :bnext<cr>


" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
  exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
  exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')


" Change hash rockets (:x => a) to new Ruby syntax (x: a)
function! RocketFix()
  %s/:\([^=,'"]*\) \?=> \?/\1: /gc
endfunction

" ignore whitespace by default when using vimdiff
if &diff
    " diff mode
    set diffopt+=iwhite
endif

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup
  command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!

endif

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

let g:ale_linters = { 'ruby': ['standardrb', 'reek']}

let g:ale_fixers = {
      \   'javascript': ['prettier'],
      \   'css': ['prettier'],
      \   'ruby': ['standardrb'],
      \}

let g:ale_fix_on_save = 1
let g:ale_set_highlights = 0 " disable highlighting
let g:ale_sign_column_always = 1
highlight clear ALEErrorSign
highlight clear ALEWarningSign

let g:ruby_heredoc_syntax_filetypes = {
        \ "xml" : {
        \   "start" : "XML",
        \},
  \}
