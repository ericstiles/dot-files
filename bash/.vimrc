" vimrc guideline
"  https://github.com/romainl/idiomatic-vimrc
"
" Indention Options
"   New lines inherit the indentation of previous lines.
set autoindent
"   Convert tabs to spaces.
set expandtab
"   Enable indentation rules that are file-type specific.
"   set filetype indent on
"   set shiftround: When shifting lines, round the indentation to the nearest multiple of “shiftwidth.”
"   set shiftwidth=4: When shifting, indent using four spaces.
"   set smarttab: Insert “tabstop” number of spaces when the “tab” key is pressed.
"   set tabstop=4: Indent using four spaces.
"   Search Options
"   set hlsearch: Enable search highlighting.
"   Ignore case when searching.
set ignorecase
"   Incremental search that shows partial matches.
set incsearch
"   set smartcase: Automatically switch search to case-sensitive when search query contains an uppercase letter.
"   Performance Options
"   vset complete-=i: Limit the files searched for auto-completes.
"   set lazyredraw: Don’t update screen during macro and script execution.
"   Text Rendering Options
"   set display+=lastline: Always try to show a paragraph’s last line.
"   Use an encoding that supports unicode.
set encoding=utf-8
"   set linebreak: Avoid wrapping a line in the middle of a word.
"   set scrolloff=1: The number of screen lines to keep above and below the cursor.
"   set sidescrolloff=5: The number of screen columns to keep to the left and right of the cursor.
"   syntax enable: Enable syntax highlighting.
"   set wrap: Enable line wrapping.
" User Interface Options
"   Always display the status bar.
set laststatus=2
"   set ruler: Always show cursor position.
"   set wildmenu: Display command line’s tab complete options as a menu.
"   set tabpagemax=50: Maximum number of tab pages that can be opened from the command line.
"   set colorscheme wombat256mod: Change color scheme.
"   set cursorline: Highlight the line currently under cursor.
"   Show line numbers on the sidebar.
set number
"   Show line number on the current line and relative numbers on all other lines.
set relativenumber
"   set noerrorbells: Disable beep on errors.
"   Flash the screen instead of beeping on errors.
set visualbell
"   set mouse=a: Enable mouse for scrolling and resizing.
"   Set the window’s title, reflecting the file currently being edited.
set title
"   set background=dark: Use colors that suit a dark background.
"   Code Folding Options
"   set foldmethod=indent: Fold based on indention levels.
"   set foldnestmax=3: Only fold up to three nested levels.
"   set nofoldenable: Disable folding by default.
"   Miscellaneous Options
"   set autoread: Automatically re-read files if unmodified inside Vim.
"   set backspace=indent,eol,start: Allow backspacing over indention, line breaks and insertion start.
"   Directory to store backup files.
set backupdir=~/.vim_backup
"   set confirm: Display a confirmation dialog when closing an unsaved file.
"   Directory to store swap files.
set dir=~/.vim_cache
"   set formatoptions+=j: Delete comment characters when joining lines.
"   set hidden: Hide files in the background instead of closing them.
"   Increase the undo limit.
set history=1000
"   set nomodeline: Ignore file’s mode lines; use vimrc configurations instead.
"   set noswapfile: Disable swap files.
"   set nrformats-=octal: Interpret octal as decimal when incrementing numbers.
"   set shell: The shell used to execute commands.
"   set spell: Enable spellchecking.
"   set wildignore+=.pyc,.swp: Ignore files matching these patterns when opening files based on a glob pattern.