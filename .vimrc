""""""""""""""""""""""""""""""""""""""""""
" Useful guides...
"
"    http://amix.dk/vim/vimrc.html 
"
""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""
" Get out of VI's compatible mode...
set nocompatible

" Number of lines of history to remember.
set history=9999

" Enable filetype plugin.
filetype plugin on
filetype indent on



"""""""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting.
syntax enable



"""""""""""""""""""""""""""""""""""""""""""
" Fileformats
"""""""""""""""""""""""""""""""""""""""""""
" Favorite filetypes.
set ffs=unix,dos,mac



"""""""""""""""""""""""""""""""""""""""""""
" VIM userinterface
"""""""""""""""""""""""""""""""""""""""""""
" Always show current position.
set ruler

" Show line numbers.
set nu

" Set backspace...
set backspace=eol,start,indent

" Bbackspace and cursor keys to wrap to...
set whichwrap+=<,>,h,l

" Ignore case when searching.
"set ignorecase
"set incsearch

" No sound on errors.
set noerrorbells

" Show matching braces.
set showmatch

" Highlight search results.
set hlsearch



"""""""""""""""""""""""""""""""""""""""""""
" Files and backups.
"""""""""""""""""""""""""""""""""""""""""""
" Turn backup off.
set nobackup
set nowb
set noswapfile



"""""""""""""""""""""""""""""""""""""""""""
" Text options.
"""""""""""""""""""""""""""""""""""""""""""
set expandtab
set shiftwidth=4
set tabstop=4
set textwidth=74
set smarttab

"""""""""""""""""""""""""""""""""""""""
" Indent.
"""""""""""""""""""""""""""""""""""""""
" Auto indent.
set ai

" Smart indent.
"set si

" C-style indenting.
set cindent

" Don't wrap lines.
set nowrap

