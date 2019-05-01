func!  MdIab()

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

func! Md2Doc()
    let dir=SafeMakeDir(g:docdir)
    let cmd ="pandoc -s --mathjax --wrap=preserve --columns=80 "
    let cmd.="-f markdown+tex_math_dollars -t docx "
    let cmd.=expand("%"). " -o " .dir. expand("%:r").".docx"

    return job_start(cmd, {'callback': 'Handler'})
    "return job_start(cmd)
endfunc 

func! Md2Htm()
    let dir=SafeMakeDir(g:htmdir)
    let cmd="pandoc -s --mathjax --wrap=preserve --columns=80 --toc "
    let cmd.="-f markdown+tex_math_dollars -t html  --track-changes=accept "
    let cmd.=expand("%"). " -o " . expand("%:r").".html"

    return job_start(cmd, {'callback': 'Handler'})
    "return job_start(cmd)
endfunc 

func! PrvHtm()
    " TODO 
    if has('win32')
        let cmd=""
        let cmd.=expand("%:r").".html"
    elseif has('linux')
        let cmd ="firefox --new-window"
        let cmd.=expand("%:r").".html"."2> /dev/null"
    elseif has('macos')
        
    endif

    return job_start(cmd, {'callback': 'Handler'})
endfunc

"autocmd BufWritePost * call system("ctags -R") 

function! vimpan#mainfunc()
    setlocal spelllang=en_us,cjk
    set wrap
    set filetype=markdown
    set fillchars=

    call Md2Doc()
    call Md2Htm()
endfunc

if !exists('g:imgdir')
    let g:imgdir = 'imgs'
endif
if !exists('g:docdir')
    let g:docdir = 'docx'
endif
if !exists('g:htmdir')
    let g:htmdir = 'html'
endif
