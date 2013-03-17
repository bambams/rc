""""""""""""""""""""""""""""""""""""""""""
" Useful guides...
"
"    http://amix.dk/vim/vimrc.html 
"
""""""""""""""""""""""""""""""""""""""""""


" Remove ALL automatic-commands from previous sources.
autocmd!

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
set fencs=ucs-bom,utf-8,latin-1

" Default file type is UTF-8.
setglobal fenc=utf-8



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

" This apparently will make gVim maximize by default.
au GUIEnter * simalt ~x


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
set nojoinspaces
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


""""""""""""""""""""""""""""""""""""""""""
" Temporary for Whitespace. >:)
""""""""""""""""""""""""""""""""""""""""""
"set list
"set listchars=eol:$,tab:>-
"set noexpandtab
"set noautoindent

"""""""
" http://nvie.com/posts/how-i-boosted-my-vim/
"""""""
" Use f2 to toggle paste mode on and off.
set pastetoggle=<F2>

" Move down a row instead of a line. Helpful when wrapping is on and you
" have long lines.
nnoremap j gj
nnoremap k gk

" ,/ stops hilighting search query.
nmap <silent> ,/ :nohlsearch<CR>


"""""""""""""""""""
" Changelog config...
""""""""""""""""""
let packager = "Brandon McCaig <bamccaig@gmail.com>"
let spec_chglog_release_info = 1

"""""""""""""""""""
" Automatic commands.
"""""""""""""""""""

autocmd FileType aspvbs setlocal ic tw=0|
           \ noremap ,, s" & vbNewline & _<CR>"    <ESC>|
           \ noremap ,. s" & vbNewline & _<CR>"<ESC>|
           \ noremap ,<CR> A & vbNewline & _<ESC>j|
           \ noremap ,e i)<ESC>|
           \ noremap ,h iToHTML(<ESC>|
           \ noremap ,i iToIndex(<ESC>|
           \ noremap ,I iToDbIndex(<ESC>|
           \ noremap ,l iToLong(<ESC>|
           \ noremap ,L iToDbLong(<ESC>|
           \ noremap ,s iToTrimString(<ESC>|
           \ noremap ,S iToDbString(<ESC>|
           \ noremap ,u iServer.UrlEncode(<ESC>|
           \ noremap ,U gUw|
           \ inoremap <ESC><tab> <C-O>i    |

autocmd FileType diff
            \ nnoremap ,, :call UndoPatch()<CR>|
            \ nnoremap ,. :s/^ /-/e<CR>:nohl<CR>j

autocmd FileType gitcommit setlocal fo+=a noai nocin nosi tw=72|
            \ noremap ,, :setlocal fo+=a<CR>|
            \ noremap ,. :setlocal fo-=a<CR>

autocmd FileType mail
            \ setlocal noai nocin nosi tw=65 wrap|
            \ noremap ,, :set formatoptions+=a<CR>|
            \ noremap ,. :set formatoptions-=a<CR>|
            \ noremap ,p :g/^X-PGP-Key:/d<CR>|
            \ noremap ,s :w<CR>:! swap-sigs.pl %<CR>
            \         :edit +set\ ft=mail<CR>|
            \ noremap ,x :.,$g/^>/d<CR>

function! UndoPatch()
    normal! 0

    if getline('.') =~ '^+'
        delete
        return
    endif

    if getline('.') =~ '^-'
        s/^-/ /
        nohlsearch
    endif

    normal! j
    normal! ^
endfunction
