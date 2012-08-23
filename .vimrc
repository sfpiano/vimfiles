" use indents of 2 spaces
set shiftwidth=2
" make indents multiples of shiftwidth
set shiftround
" replace tabs w/spaces
set expandtab
set autoindent
set nowrap
set tabstop=2

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
" in makefiles, don't expand tabs to spaces, since actual tab characters are
" needed, and have indentation at 8 chars to be sure that all indents are tabs
" (despite the mappings later):
autocmd FileType make setlocal noexpandtab shiftwidth=8
" highlight lines longer than 80 chars
highlight Overflow ctermbg=red ctermfg=white
autocmd FileType c,cc,cpp,h,hh,hpp,perl,python match Overflow /\%82v.*/

" GPB
augroup filetype
  "au! BufRead,BufNewFile *.proto setfiletype proto
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
"set tags=/home/path/to/tagsfile
" Automatically close the omnicpp Scratch/Preview buffer
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif 

" Code templates
map <silent> cc :exe 'so /home/sfpiano/vimTemplates/source'<CR>
map <silent> hh :exe 'so /home/sfpiano/vimTemplates/header'<CR>
map <silent> df :exe 'so /home/sfpiano/vimTemplates/cFn'<CR>
map <silent> hf :exe 'so /home/sfpiano/vimTemplates/hFn'<CR>
map <silent> snip :exe 'so /home/sfpiano/vimTemplates/snip'<CR>
map <silent> del :exe 'so /home/sfpiano/vimTemplates/del'<CR>
map <silent> df :exe 'so /home/sfpiano/vimTemplates/dump'<CR>

" Navigate windows
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" Append copied text to our custom dictionary file
nmap <silent> <f4> :exe ':!echo '.expand("<cword>").' >> /home/sfpiano/Dict'<CR>

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
map ww <esc>:w!

com! -nargs=1 Proto call Proto(<f-args>)
fun! Proto(str)
  exec '%s/'.a:str.'//'
  exec 'g/^$/d'
  exec 'g/\s\+\/\/.*/d'
  exec '%s/[A-Z]\+_\%[T_]\?'

  exec 1
  let curline = 1
  let lastline = line('$')
  while curline < lastline
    let start = search('{', 'W')
    let stopp = search('}', 'W')
    exec start.','.stopp.'Tab/='
    let curline = stopp
  endwhile
endfun

"command! -nargs=* -range Transform <line1>,<line2> call Transform(<f-args>)
command! -nargs=1 -range Fnsort <line1>,<line2> call Fnsort(<f-args>)
fun! Fnsort(type) range
  "Fnsort c/h
  " Search through the text looking for comment blocks. When found wrap the
  " function in start/end delimiters for the next step
  
  let curLineNumber = a:firstline
  " Used to see if we've matched two lines in a row
  let prevMatch = 0
  let matchLineNumberStart = 0
  while curLineNumber < a:lastline
    let line = getline(curLineNumber)
    "let fnmatch = match(line, '\s*\/\/-\+\n\s*\/\/-\+$')
    " Functions are assumed to be delimited by two lines of //---* potentially
    " with doxygen comments in between
    let fnmatch = match(line, '\s*\/\/-\+$')

    if fnmatch >= 0
      if prevMatch == 1
        " Add a marker to the start of the function block
        call setline(matchLineNumberStart, 'FNSTART'.line)

        " C functions end with a }, H functions end with a ;
        if a:type == 'c'
          call search('^{', 'W')
          let lastline = search('^}', 'W')
        else
          let lastline = search(';', 'W')
        endif

        " Add a marker to the end of the function block
        call setline(lastline, getline(lastline).'FNEND')
        let prevMatch = 0
      else
        let matchLineNumberStart = curLineNumber
        let prevMatch = 1
      endif
    endif

    let curLineNumber += 1
  endwhile

  " Join all of the function block text onto one line
  let range = a:firstline . ',' . a:lastline
  exe range . 'g/FNSTART\%[\w]!\=/,/FNEND/ s/$\n/@@@'

  " Find the new line count now that we've deleted a bunch of lines
  exec a:firstline
  let lastline = search('^[^FNSTART]', 'nW') - 1
  if lastline < 0
    let lastline = line('$')
  endif

  " Sort the function text and split the lines back up
  " FNSTART//------@@@//------@@@GLSYS_VOID@@@fn()@@@{@@@  foo();@@@}FNEND@@@
  let range = a:firstline . ',' . lastline
  if a:type == 'c'
    exe range . "sort/\\w@@@/"
  else
    exe range . 'sort/\/\/-\+@@@.*\/\/-\+@@@.\{-}@@@/'
  endif
  exe range . "s/@@@/\\r/g"

  " Delete the delimiters we added earlier
  let range = a:firstline . ',' . a:lastline
  exe range . 's/FN[START\|END]\+'
  "exe range . "s/FNEND//"

  "g/GLSYS_\%[\w]!\=/,/ENDGLSYS/ s/$\n/@@@
  "sort /GLSYS_\w*@@@\=/
  "s/@@@/\r/g
endfun

command! -nargs=0 -range Comment <line1>,<line2> call Comment()
fun! Comment() range
  " Current line number
  let curline = 0
  " Number of added lines
  let newlines = 0
  let lastline = a:lastline

  " If no range specifed, use whole file
  if a:firstline == 1 && lastline == 1
    let lastline = line('$')
  endif

  while curline <= lastline
    " Mark the curline where the comment should be added 
    let marker = search('/\*\*', 'W')
    " Find the curline with the functon decl
    let curline = search('[G|S]et', 'W')
    " Check if this a get or a set function
    let getfn = match(getline(curline), '^\s*G')

    if marker != 0 && curline >= a:firstline && curline <= lastline+newlines
      " Copy the text after 'G/Set' into a buffer
      normal 3l
      normal "ryw

      " Search for one function argument
      let paramMarker = search('\w)', 'W', curline)
      if paramMarker != 0
        normal b
        normal "pyw
      endif

      " Jump back to where the comment should be added and add a new line
      exec marker
      let marker += 1
      let newlines += 1
      normal o

      " Add the param comment if applicable
      if paramMarker != 0
        if getfn == -1
          call setline(marker, getline(marker).' Sets the '.@r)
          let marker += 1
          let newlines += 1
          normal o
        endif

        call setline(marker, getline(marker).' @param '.@p.' The '.@r)
      endif

      " Add the return comment if applicable
      if getfn > -1
        " If we already added a line for a parameter, add a new line for the
        " return value (otherwise the new line will already be there)
        if paramMarker != 0
          let marker += 1
          let newlines += 1
          normal o
        endif

        call setline(marker, getline(marker).' @return The '.@r)
      endif
    endif
  endwhile

endfun
