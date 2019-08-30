func!  vimpan#MdIab()

    iab iday <c-r>=strftime("20%y年%m月%d日 %H:%M:%S")<cr> 
    iab ss <!--{{{-->
    iab ee <!--}}}-->

    iab sum <c-r>=strftime("\\sum^{}_{}")<cr><ESC>3h
    iab inf <c-r>=strftime("\\infty^{}_{}")<cr><ESC>3h
    iab fr <c-r>=strftime("\\frac{}{}")<cr><ESC>2h
    iab ff <c-r>=strftime("\$f(x) = a_0 + 
                \\\sum^{\\infty}_{k=1} a_k \\cos(kx) + b_k \\sin(kx)\$"
                \)<cr><ESC>
endfunc

func! Handler(channel, msg)
    echo a:msg 
endfunc

function! SafeMakeDir(dirname) 
    if has('win32')
        let outdir = expand('%:p:h') . '\' . a:dirname. '\' 
    else
        let outdir = expand('%:p:h') . '/' . a:dirname. '/' 
    endif
    if !isdirectory(outdir)
        call mkdir(outdir)
    endif
    return fnameescape(outdir)
endfunction

func! vimpan#Md2Doc()
    let dir=SafeMakeDir(g:outdir)
    let cmd ="pandoc -s --mathjax --wrap=preserve --columns=80 "
    let cmd.="-f markdown+east_asian_line_breaks+pipe_tables "
    let cmd.="--data-dir=".g:datdir." "
    if filereadable(g:datdir."reference.docx")
        let cmd.="--reference-doc=".g:datdir."reference.docx "
    endif

    if filereadable(expand("%:r").".bib")
        let cmd.="--filter pandoc-citeproc --bibliography=".expand("%:r").".bib "
    elseif filereadable("ref.bib")
        let cmd.="--filter pandoc-citeproc --bibliography=ref.bib "
    endif
   
    let cmd.="-t docx ".expand("%"). " -o " .dir. expand("%:r").".docx"

    "echom cmd
    return job_start(cmd, {'callback': 'Handler'})
    "return job_start(cmd)
endfunc 

func! vimpan#Md2Htm()
    let dir=SafeMakeDir(g:outdir)
    let cmd="pandoc -s --mathml --wrap=preserve --columns=80 --toc "
    let cmd.="-f markdown+east_asian_line_breaks+pipe_tables "
    let cmd.="--data-dir=".g:datdir." "
    if filereadable(expand("%:r").".css")
        let cmd.="--css=".expand("%:r").".css "
    elseif filereadable("ref.css")
        let cmd.="--css=ref.css "
    endif

    if filereadable(expand("%:r").".bib")
        let cmd.="--filter pandoc-citeproc --bibliography=".expand("%:r").".bib "
    elseif filereadable("ref.bib")
        let cmd.="--filter pandoc-citeproc --bibliography=ref.bib "
    endif
   
    "let cmd.="--resource-path=".g:datdir." "
    let cmd.="-t html ".expand("%"). " -o ". expand("%:r").".html"

    "echom cmd
    return job_start(cmd, {'callback': 'Handler'})
    "return job_start(cmd)
endfunc 

func! vimpan#PrvHtm()
    " TODO 
    if has('win32')
        let cmd=""
        let cmd.=expand("%:r").".html"
    elseif has('unix')
        let cmd ="firefox  --new-window "
        let cmd.=expand("%:r").".html"
    elseif has('macos')
        
    endif

    echom cmd

    return job_start(cmd, {'callback': 'Handler'})
endfunc

"autocmd BufWritePost * call system("ctags -R") 

function! vimpan#AutoGen()
    call vimpan#Md2Doc()
    call vimpan#Md2Htm()
endfunc

func! vimpan#Main() abort

    call vimpan#MdIab()

    let g:tagbar_type_markdown = { 
            \ 'ctagstype' : 'markdown',
            \ 'deffile' :g:datdir.'markdown.ctags',
            \ 'kinds' : [
            \ 'h:headings',
            \ ],
            \ 'sort' : 0
            \ }

endfunc

if !exists('g:datdir')
    let g:datdir =expand('<sfile>:p:h:h').'/data/'
endif

if !exists('g:imgdir')
    let g:imgdir = 'img'
endif
if !exists('g:outdir')
    let g:outdir = ''
endif


