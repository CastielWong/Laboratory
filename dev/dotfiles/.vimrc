

" this file is normally placed under user's HOME directory


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"               ██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"               ██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"               ██║   ██║██║██╔████╔██║██████╔╝██║
"               ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║
"                ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" reference:
" - https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/
" - https://realpython.com/vim-and-python-a-match-made-in-heaven

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Config - general

" disable compatibility with vi which can cause unexpected issues
set nocompatible

" do not save backup files
set nobackup

" set the commands to save in history default number is 20
"set history=1000

" block files that would never edit with Vim
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" enable auto completion menu after pressing TAB
"set wildmenu
" make wildmenu behave like similar to Bash completion
"set wildmode=list:longest

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Config - display
" enable type file detection. Vim will be able to try to detect the type of file is use
filetype on

" enable plugins and load plugin for the detected file type
filetype plugin on

" load an indent file for the detected file type
filetype indent on

" add numbers to the file
set number

" turn syntax highlighting on
syntax on

" enable cursor position display
set ruler

" highlight cursor line underneath the cursor horizontally and vertically
set cursorline cursorcolumn

" visualize the invisible tab
set invlist

" show the mode you are on the last line
"set showmode

" show partial command you type in the last line of the screen
set showcmd


" do not let cursor scroll below or above N number of lines when scrolling
"set scrolloff=10

" visualize space with '_', tab with '>~'
"set listchars=space:_,tab:>~

" allow long lines to extend as far as the line goes
"set nowrap

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Config - indent
" enable auto-indentation
set autoindent

" replace tab with spaces
set expandtab

" set tab's width to be equal to N spaces/columns
set tabstop=2

" set to N spaces when apply auto-indentation via `>>`
set shiftwidth=2

" ?
set softtabstop=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Config - text
set textwidth=80

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Config - search

" highlight matching characters while typing to search though a file incrementally
set incsearch

" highlight when doing a search
set hlsearch

" ignore capital letters during search
"set ignorecase
" make searching capital-sensitive
set smartcase

" show matching words during a search
"set showmatch

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" STATUS LINE ------------------------------------------------------------ {{{

" show the status on the second to last line
set laststatus=2

" clear status line when vimrc is reloaded
set statusline=

" set status line on the left side
set statusline+=\ %F\ %M\ %Y\ %R

" sse a divider to separate the left side from the right side
set statusline+=%=

" set status line on the right side
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%

" }}}


" PLUGINS ---------------------------------------------------------------- {{{

" }}}


" MAPPINGS --------------------------------------------------------------- {{{

" NERDTree specific mappings.
" Map the F3 key to toggle NERDTree open and close.
nnoremap <F3> :NERDTreeToggle<cr>

" Have nerdtree ignore certain files and directories.
let NERDTreeIgnore=['\.git$', '\.jpg$', '\.mp4$', '\.ogg$', '\.iso$', '\.pdf$', '\.pyc$', '\.odt$', '\.png$', '\.gif$', '\.db$']

" }}}


" VIMSCRIPT -------------------------------------------------------------- {{{

" }}}
