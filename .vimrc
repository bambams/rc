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

" Disable the mouse (hopefully).
set mouse=


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
" Hex editing.
"""""""""""""""""""
" source: http://vim.wikia.com/wiki/Improved_hex_editing
nnoremap ,h :Hexmode<CR>
inoremap <C-,h> <Esc>:Hexmode<CR>
vnoremap <C-,h> :<C-U>Hexmode<CR>

" ex command for toggling hex mode - define mapping if desired
command! -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function! ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    silent :e " this will reload the file without trickeries
              "(DOS line endings will be shown entirely )
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

" autocmds to automatically enter hex mode and handle file writes properly
if has("autocmd")
  " vim -b : edit binary using xxd-format!
  augroup Binary
    au!

    " set binary option for all binary files before reading them
    au BufReadPre *.bin,*.dat,*.hex setlocal binary

    " if on a fresh read the buffer variable is already set, it's wrong
    au BufReadPost *
          \ if exists('b:editHex') && b:editHex |
          \   let b:editHex = 0 |
          \ endif

    " convert to hex on startup for binary files automatically
    au BufReadPost *
          \ if &binary | Hexmode | endif

    " When the text is freed, the next time the buffer is made active it will
    " re-read the text and thus not match the correct mode, we will need to
    " convert it again if the buffer is again loaded.
    au BufUnload *
          \ if getbufvar(expand("<afile>"), 'editHex') == 1 |
          \   call setbufvar(expand("<afile>"), 'editHex', 0) |
          \ endif

    " before writing a file when editing in hex mode, convert back to non-hex
    au BufWritePre *
          \ if exists("b:editHex") && b:editHex && &binary |
          \  let oldro=&ro | let &ro=0 |
          \  let oldma=&ma | let &ma=1 |
          \  silent exe "%!xxd -r" |
          \  let &ma=oldma | let &ro=oldro |
          \  unlet oldma | unlet oldro |
          \ endif

    " after writing a binary file, if we're in hex mode, restore hex mode
    au BufWritePost *
          \ if exists("b:editHex") && b:editHex && &binary |
          \  let oldro=&ro | let &ro=0 |
          \  let oldma=&ma | let &ma=1 |
          \  silent exe "%!xxd" |
          \  exe "set nomod" |
          \  let &ma=oldma | let &ro=oldro |
          \  unlet oldma | unlet oldro |
          \ endif
  augroup END
endif

"""""""""""""""""""
" Automatic commands.
"""""""""""""""""""

noremap <C-X> :call StripPatchMarkers()<CR>

autocmd FileType aspvbs setlocal ic tw=0|
           \ noremap ,, s" & vbNewline & _<CR>"   <ESC>|
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
            \ nnoremap ,. :s/^ /-/e<CR>:nohl<CR>jzz|
            \ nnoremap ,c :call DiffColor()<CR>

autocmd FileType gitcommit setlocal fo+=a noai nocin nosi tw=72|
            \ noremap ,, :setlocal fo+=a<CR>|
            \ noremap ,. :setlocal fo-=a<CR>

autocmd FileType hgcommit setlocal fo+=a noai nocin nosi tw=72|
            \ setlocal comments+=b:HG:|
            \ noremap ,, :setlocal fo+=a<CR>|
            \ noremap ,. :setlocal fo-=a<CR>|
            \ noremap ,b :call HgBranch()<CR>|
            \ noremap ,B :call HgTopBranch()<CR>

autocmd FileType mail
            \ setlocal noai nocin nosi tw=65 wrap|
            \ noremap ,, :set formatoptions+=a<CR>|
            \ noremap ,. :set formatoptions-=a<CR>|
            \ noremap ,p :g/^X-PGP-Key:/d<CR>|
            \ noremap ,s :w<CR>:! swap-sigs.pl %<CR>
            \         :edit +set\ ft=mail<CR>|
            \ noremap ,x :.,$g/^>/d<CR>

" h4x: Google uses 2 space indentation and I'm trying to work on their
" Python tutorial.
autocmd FileType python setlocal sw=2 ts=2

" h4x: A simple function to replace vimdiff colors with reds and greens.
" This may be easier to read on some terminals, but not necessarily all.
" For now I am only including in in here so I can easily use it if I want.
" Originated here:
" <http://vim.1045645.n5.nabble.com/vimdiff-colors-tp1173870p1173871.html>
function! DiffColor()
    highlight DiffAdd term=reverse cterm=bold ctermbg=green ctermfg=white
    highlight DiffChange term=reverse cterm=bold ctermbg=cyan ctermfg=black
    highlight DiffText term=reverse cterm=bold ctermbg=gray ctermfg=black
    highlight DiffDelete term=reverse cterm=bold ctermbg=red ctermfg=black
endfunction

function! UndoPatch()
    normal! 0

    if getline('.') =~ '^+'
        delete
        normal! zz
        return
    endif

    if getline('.') =~ '^-'
        s/^-/ /
        nohlsearch
    endif

    normal! j
    normal! ^
    normal! zz
endfunction

function! HgCdRoot()
    cd $HG_CD_ROOT
endfunction

function! HgBranch()
    call HgCdRoot()
    r! hg branch
    normal! k
    normal! J
endfunction

function! HgTopBranch()
    call HgCdRoot()
    read! hg branches | head -n 1 |
            \ perl -nE "/(.*) [0-9]+:[a-f0-9]{12}$/ and print qq/$1\n/"
endfunction

function! StripPatchMarkers()
    :'<,'>s/^+//e
    :'<,'>s///e
endfunction

"""""""""""""""""""""""""""
" h4x: Background coloring.
"""""""""""""""""""""""""""
set background=dark
