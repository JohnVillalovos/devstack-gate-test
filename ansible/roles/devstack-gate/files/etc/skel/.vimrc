" I use a black background
set background=dark

"turn on syntax highlighting
syntax enable
"Have syntax highlighting process from start of file, to avoid vim getting
"confused. This might cause longer load times
autocmd BufEnter * :syntax sync fromstart

" By default expand tabs
set expandtab

"these characters can move past end of line
set whichwrap=b,s,h,l

"autoindent on
set autoindent

"Turn on wildmenu
set wildmenu

"Show command
set showcmd

"show matching bracket
set showmatch

" Set status
set laststatus=2

"use standard tab stop of 8
set tabstop=8
"use softtabs of 4
set softtabstop=4
"use shiftwidth of 4
set shiftwidth=4

"When searching ignore that case but also use the smartcase feature
set ignorecase
set smartcase

"Use incremental searching
set incsearch

"Display the ruler
set ruler
"Highlight the search
set hlsearch


"Status line setup
" Show full path to file
set statusline=%F
" Indicate if modified
set statusline+=\ %m
" Git status using https://github.com/tpope/vim-fugitive plugin
"set statusline+=\ %{fugitive#statusline()}
" Type of file in the buffer (filetype)
set statusline+=\ %y
" Go to right side of statusline
set statusline+=%=
" Line and character count
set statusline+=%4l,%2c
" Percentage of file
set statusline+=\ \ %P

"Make sure we keep 4 lines of text between the cursor and the
"top/bottom of page
set scrolloff=4

"Use the visual bell
set visualbell

autocmd BufRead,BufNewFile /opt/stack/logs/* set filetype=openstack

if has("autocmd")
    " Enable file type detection
    filetype plugin indent on

    " Have Vim jump to the last position when reopening a file
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
