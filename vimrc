" use indents of 2 spaces
set shiftwidth=2
" make indents multiples of shiftwidth
set shiftround
" replace tabs w/spaces
set expandtab
set autoindent
set nowrap
set tabstop=2
"set mouse=a

filetype on
filetype plugin on
" for C-like programming, have automatic indentation:
autocmd FileType c,cc,cpp,h,hh,hpp,perl set cindent
autocmd FileType c,cc,cpp,h,hh,hpp,perl set textwidth=79
" for actual C (not C++) programming where comments have explicit end
" characters, if starting a new line in the middle of a comment automatically
" insert the comment leader characters:
autocmd FileType c set formatoptions+=ro
autocmd FileType ii,cc,cpp setlocal syntax=cpp11
autocmd FileType perl set syntax=perl
autocmd FileType python setlocal tabstop=2
" in makefiles, don't expand tabs to spaces, since actual tab characters are
" needed, and have indentation at 8 chars to be sure that all indents are tabs
" (despite the mappings later):
autocmd FileType make setlocal noexpandtab shiftwidth=8
" highlight lines longer than 80 chars
highlight Overflow ctermbg=red ctermfg=white
autocmd FileType c,cc,cpp,h,hh,hpp,perl,python match Overflow /\%82v.*/

" GPB
augroup filetype
  au! BufRead,BufNewFile *.proto setlocal syntax=proto
augroup end

" Autoload Doxygen highlighting
let g:load_doxygen_syntax=1

" make searches case-insensitive, unless they contain upper-case letters:
set ignorecase
set smartcase
" show the `best match so far' as search strings are typed:
set incsearch

" Only spell check code files
autocmd FileType c,cc,cpp,h,hh set spell
autocmd FileType c,cc,cpp,h,hh set spelllang=en_us,fromtags
highlight clear SpellBad
highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
highlight Comment ctermfg=6
set infercase
" autocorrect
abbreviate teh the

set nocp
" Tell vi to recursively search upwards to find the tags file
" Automatically close the omnicpp Scratch/Preview buffer
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif 

" Code templates

" Navigate windows
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" Make editing vimrc easier
map ,v :sp $VIMRC<CR><C-W>_
map <silent> ,V :source $VIMRC<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
map cn <esc>:cn<cr>
map cp <esc>:cp<cr>
map ga <esc>:tabp<cr>
map cheaders <esc>:%s/\/\*\*\n.*\*\/\n//<cr>
map cs <esc>:s/(\(.*\))\(\w*\)/static_cast< \1 >(\2)/g<cr>

map tt :Tab/=<cr>
"map cheaders <esc>:%s/\/\*\*\n  \*\/\n//<cr>

" Insert new lines without going into insert mode
map <S-Enter> O<Esc>
map <CR> o<Esc>

" aliases

" Quick disable highlighting after searching
let mapleader = ","
nnoremap <leader><space> :noh<cr>


