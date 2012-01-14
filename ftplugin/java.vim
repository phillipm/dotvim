" JavaRun.vim
" Version 0.2
" Kendrew Lau
"
" Script to save, compile, and run the Java program in current buffer.
" The saving and compilation are only done if necessary.
" Some abbreviations for Java programming are added, e.g.
"   psvm for "public static void main(String[] args) { }"
"   cl for class
"   fi for final
" (This is inspired by Netbeans)
" See the end of this script for the list of abbreviations.
"
" Also, save and run for Python, Perl, Ruby, Tcltk, and Clisp file.
"
" To use it, source this script and do the command :Run [arg...]
" where arg are optional arguments to the Java program to run
" Alternatively, just press <F5> to run without arguments.
"

"JCommenter Config
" map the commenter:
map <F4> :call JCommentWriter()<CR>
imap <F4> <esc>:call JCommentWriter()<CR>

" add comments when new java file opens
if !exists("d:JavaCommenter")
    fun! d:JavaCommenter()
        call JCommentWriter()
        call append(0,"package ".expand("%:p:h:t").";")
        call append(line('$'), "public class ".expand("%:t:r")." {")
        call append(line('$'), "}")
        call cursor(line('$')-1,0)
    endf
endif

"call d:JavaCommenter()

function! JavaRun(...)
	update
	let e = 0
	if getftime(expand("%:r") . ".class") < getftime(expand("%"))
		make
		let e = v:shell_error
	endif
	if e == 0
		let idx = 1
		let arg = ""
		while idx <= a:0
			execute "let a = a:" . idx
			let arg = arg . ' ' . a
			let idx = idx + 1
		endwhile
		execute "!java " . expand("%:r") . " " . arg
	endif
endfunction

function! ProgRun(...)
	update
	let e = 0
	let ext = expand("%:e")
	if ext == "java" && getftime(expand("%:r") . ".class") < getftime(expand("%"))
		make
		let e = v:shell_error
	endif
	if e == 0
		if exists("g:runprogstring")
			execute "!" . g:runprogstring
		else
			let idx = 1
			let arg = ""
			while idx <= a:0
				execute "let a = a:" . idx
				let arg = arg . ' ' . a
				let idx = idx + 1
			endwhile
			cd %:p:h:h
			if ext == "java"
				execute "!java " . expand("%:r") . " " . arg
			elseif ext == "py"
				execute "!python " . expand("%") . " " . arg
			elseif ext == "pl"
				execute "!perl " . expand("%") . " " . arg
			elseif ext == "rb"
				execute "!ruby " . expand("%") . " " . arg
			elseif ext == "tcl"
				execute "!tclsh " . expand("%") . " " . arg
			elseif ext == "lisp"
				execute "!clisp " . expand("%") . " " . arg
			endif
			cd -
		endif
	endif
endfunction


set shellpipe=>\ %s\ 2>&1
set makeprg=javac\ -target\ 1.7\ -classpath\ \"$CLASSPATH:%:p:h:h\\"\ \"%\"
"set makeprg=javac\ -target\ 1.5\ -classpath\ C:\Documents\ and\ Settings\Matey\My\ Documents\workspace\ %
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
" set makeprg=jikes\ +E\ %
" set errorformat=%f:%l:%v:%*\\d:%*\\d:%*\\s%m

command! -nargs=* JavaRun call JavaRun(<f-args>)
command! -nargs=* Run call ProgRun(<f-args>)

iab psvm public static void main(String[] args) <HOME>{<HOME>}<UP><END>
iab sout System.out.println();<LEFT><LEFT>
iab serr System.err.println();<LEFT><LEFT>
