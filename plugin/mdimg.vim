"For images: Introduced form  ------------------------------------------------"

function! SaveFileTMPLinux(imgdir, tmpname) abort
    let targets = filter(
                \ systemlist('xclip -selection clipboard -t TARGETS -o'),
                \ 'v:val =~# ''image''')
    if empty(targets) | return 1 | endif

    let mimetype = targets[0]
    let extension = split(mimetype, '/')[-1]
    let tmpfile = a:imgdir . '/' . a:tmpname . '.' . extension
    call system(printf('xclip -selection clipboard -t %s -o > %s',
                \ mimetype, tmpfile))
    return tmpfile
endfunction

function! SaveFileTMPWin32(imgdir, tmpname) abort
    let tmpfile = a:imgdir . '/' . a:tmpname . '.png'

    let clip_command = "Add-Type -AssemblyName System.Windows.Forms;"
    let clip_command .= "if ($([System.Windows.Forms.Clipboard]::ContainsImage())) {"
    let clip_command .= "[System.Drawing.Bitmap][System.Windows.Forms.Clipboard]::GetDataObject().getimage().Save('"
    let clip_command .= tmpfile ."', [System.Drawing.Imaging.ImageFormat]::Png) }"
    let clip_command = "powershell -sta \"".clip_command. "\""

    silent call system(clip_command)
    if v:shell_error == 1
        return 1
    else
        return tmpfile
    endif
endfunction

function! SaveFileTMPMacOS(imgdir, tmpname) abort
    let tmpfile = a:imgdir . '/' . a:tmpname . '.png'
    let clip_command = 'osascript'
    let clip_command .= ' -e "set png_data to the clipboard as «class PNGf»"'
    let clip_command .= ' -e "set referenceNumber to open for access POSIX path of'
    let clip_command .= ' (POSIX file \"' . tmpfile . '\") with write permission"'
    let clip_command .= ' -e "write png_data to referenceNumber"'

    silent call system(clip_command)
    if v:shell_error == 1
        return 1
    else
        return tmpfile
    endif
endfunction

function! SaveFileTMP(imgdir, tmpname)
    if has('mac')
        return SaveFileTMPMacOS(a:imgdir, a:tmpname)
    elseif has('win32')
        return SaveFileTMPWin32(a:imgdir, a:tmpname)
    else
        return SaveFileTMPLinux(a:imgdir, a:tmpname)
    endif
endfunction

function! SaveNewFile(imgdir, tmpfile)
    let extension = split(a:tmpfile, '\.')[-1]
    let reldir = g:imgdir
    let cnt = 0
    let filename = a:imgdir . '/' . g:imgname . cnt . '.' . extension
    let relpath = reldir . '/' . g:_imgname . cnt . '.' . extension
    while filereadable(filename)
        call system('diff ' . a:tmpfile . ' ' . filename)
        if !v:shell_error
            call delete(a:tmpfile)
            return relpath
        endif
        let cnt += 1
        let filename = a:imgdir . '/' . g:imgname . cnt . '.' . extension
        let relpath = reldir . '/' . g:imgname . cnt . '.' . extension
    endwhile
    if filereadable(a:tmpfile)
        call rename(a:tmpfile, filename)
    endif
    return relpath
endfunction

function! mdimg#MarkdownClipboardImage()
    let workdir = SafeMakeDir()
    " change temp-file-name and image-name
    let g:tmpname = RandomName()
    " let g:mdip_imgname = g:mdip_tmpname

    let tmpfile = SaveFileTMP(workdir, g:tmpname)
    if tmpfile == 1
        return
    else
        " let relpath = SaveNewFile(g:mdip_imgdir, tmpfile)
        let extension = split(tmpfile, '\.')[-1]
        let relpath = g:imgdir . '/' . g:_tmpname . '.' . extension
        execute "normal! i![Image](" . relpath . ")"
    endif
endfunction

" For file rename and delete file
function! mdimg#RenameFile(NewName) abort
    let Path=expand("<cfile>:h")."/"
    let OldName=expand("<cfile>:t:r")
    let Ext=".".expand("<cfile>:e")

    let OldPath=Path.OldName.Ext
    let NewPath=Path.a:NewName.Ext

    if filereadable(OldPath) == 1
        if filereadable(NewPath)==0
            call rename(OldPath, NewPath)
            echo "Rename ".OldName." to ".a:NewName
        else 
            echoerr NewPath." existed"
            return 
        endif
    else 
        echoerr OldPath." not existed"
        return 
    endif

    let cmd="sed -i ". "s/".OldName."/".a:NewName."/g *.md"

    silent call system(cmd)
    execute ':e'

    return
endfunction

function! mdimg#DeleteFile() abort
    let Path=expand("<cfile>:h")."/"
    let OldName=expand("<cfile>:t:r")
    let Ext=".".expand("<cfile>:e")

    let OldPath=Path.OldName.Ext

    if filereadable(OldPath) == 1
        call delete(OldPath)
    else 
        echoerr OldPath." not existed"
        return 
    endif

    let cmd="sed -i ". "/".OldName."/d *.md"

    "job_start(cmd, {'callback': 'Handler'})
    
    silent call system(cmd)
    execute ':e'

    return
endfunction
