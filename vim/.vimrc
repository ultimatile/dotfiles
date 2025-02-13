syntax on
filetype plugin indent on  
set shiftround
set confirm
set belloff=all
set spelllang=en,cjk
set linebreak 
set laststatus=3
set statusline=%y
set nocompatible
set encoding=utf-8
set number
set cursorline
set showcmd
set showmatch
set title
set wildmenu
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set noswapfile
set clipboard=unnamedplus
set splitbelow
set splitright
set mouse=a
set nofoldenable
set ttyfast 
" keymaps
" https://zenn.dev/vim_jp/articles/43d021f461f3a4
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
nnoremap <C-P> :copy.<CR>
nnoremap <C-S-P> :copy-1<CR>
xnoremap <C-P> :copy '<-1<CR>gv
xnoremap <C-S-P> :copy '>+0<CR>gv
nnoremap Y y$
nnoremap x "_d
nnoremap X "_D
xnoremap x "_x
onoremap x d
nnoremap U <c-r>
xnoremap p P
xnoremap < <gv
xnoremap > >gv
nnoremap <expr> <M-Up> $'<Cmd>move-1-{v:count1}<CR>=l'
nnoremap <expr> <M-Down> $'<Cmd>move+{v:count1}<CR>=l'
xnoremap <silent><M-Up> :move'<-2<CR>gv=gv
xnoremap <silent><M-Down> :move'>+1<CR>gv=gv
nnoremap p ]p`]
nnoremap P ]P`]

