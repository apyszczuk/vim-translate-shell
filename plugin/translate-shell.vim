" vim-translate-shell - Translate text using translate-shell application
"
" Author:     Artur Pyszczuk <apyszczuk@gmail.com>
" License:    Same terms as Vim itself
" Website:    https://github.com/apyszczuk/vim-translate-shell

if exists ('g:loaded_translate_shell')
    finish
endif
let g:loaded_translate_shell = 1


" ---------------------------------------------------------- configuration -----
let g:translate_shell_binary                = "trans"
let g:translate_shell_language              = ":"
let g:translate_shell_engine                = "auto"

let g:translate_shell_mappings_enabled      = 1
let g:translate_shell_mapping_configuration =
\ {
\     "paragraph_to_line"                   : 1
\   , "min_width_for_reformat"              : 40
\   , "window_position"                     : "horizontal" 
\ }


" ---------------------------------------------------------------- writers -----
function! s:echo(translation)
    echo join(a:translation, "\n")
endfunction


function! s:window(translation, mode)
    execute ":" a:mode . " new " . tempname()
    call append(0, a:translation)
    :write

    setlocal bufhidden=delete
    setlocal nomodifiable
endfunction


" --------------------------------------------------------------- mappings -----
function! s:selected_text()
    let tmp = @a

    :silent normal! gv"ay
    let ret = @a
    let @a = tmp

    return ret
endfunction


function! s:max_width(lst)
    let i   = 0
    let ret = 0

    while i < len(a:lst)
        let sz = len(a:lst[i])

        if sz > ret
            let ret = sz
        endif

        let i += 1
    endwhile

    return ret
endfunction


function! s:single_line_paragraphs(source)
    let ret         = []
    let paragraph   = ""
    let i           = 0

    while i < len(a:source)
        if len(a:source[i]) > 0
            " in a paragraph
            let paragraph = paragraph . a:source[i] . " "
        else
            " end of paragraph
            if len(paragraph) > 0
                call add(ret, trim(paragraph))
                let paragraph = ""
            endif
            
            " newline
            call add(ret, "")
        endif

        let i = i + 1
    endwhile

    " last paragraph
    if len(paragraph) > 0
        call add(ret, trim(paragraph))
    endif

    return ret
endfunction


function! s:translate_mapping(configuration, content, ...)
    let content_list    = split(a:content, "\n")
    let paragraphs      = a:configuration.paragraph_to_line ?
    \                     s:single_line_paragraphs(content_list) :
    \                     content_list
    let max_width       = s:max_width(content_list)

    let command = g:translate_shell_binary
    \           . " --no-ansi"
    \           . " -e " . g:translate_shell_engine


    for arg in a:000
        let command .= " " . arg
    endfor


    let content_string = ""
    for paragraph in paragraphs
        let content_string .= paragraph . "\n"
    endfor

    let content_string = escape(content_string, '"')
    let content_string = trim(content_string)

    let command .= " " . '"' . content_string . '"'


    if max_width > a:configuration.min_width_for_reformat
        let command .= " | fmt -w " . max_width
    endif

    return systemlist(command)
endfunction


nnoremap <silent> <Plug>(translate-shell-word-brief-echo)
\   :call <SID>echo
\   (
\       <SID>translate_mapping
\       (
\             g:translate_shell_mapping_configuration
\           , "<C-R>=expand("<cword>")<CR>"
\           , g:translate_shell_language
\           , "--brief"
\       )
\   )
\   <CR>

nnoremap <silent> <Plug>(translate-shell-word-brief-window)
\   :call <SID>window
\   (
\       <SID>translate_mapping
\       (
\             g:translate_shell_mapping_configuration
\           , "<C-R>=expand("<cword>")<CR>"
\           , g:translate_shell_language
\           , "--brief"
\       )
\       , g:translate_shell_mapping_configuration.window_position
\   )
\   <CR>

xnoremap <silent> <Plug>(translate-shell-selection-brief-echo)
\   :<C-U>
\   call <SID>echo
\   (
\       <SID>translate_mapping
\       (
\             g:translate_shell_mapping_configuration
\           , <SID>selected_text()
\           , g:translate_shell_language
\           , "--brief"
\       )
\   )
\   <CR>

xnoremap <silent> <Plug>(translate-shell-selection-brief-window)
\   :<C-U>
\   call <SID>window
\   (
\       <SID>translate_mapping
\       (
\             g:translate_shell_mapping_configuration
\           , <SID>selected_text()
\           , g:translate_shell_language
\           , "--brief"
\       )
\       , g:translate_shell_mapping_configuration.window_position
\   )
\   <CR>


nnoremap <silent> <Plug>(translate-shell-word-verbose-echo)
\   :call <SID>echo
\   (
\       <SID>translate_mapping
\       (
\             g:translate_shell_mapping_configuration
\           , "<C-R>=expand("<cword>")<CR>"
\           , g:translate_shell_language
\           , "--verbose"
\       )
\   )
\   <CR>

nnoremap <silent> <Plug>(translate-shell-word-verbose-window)
\   :call <SID>window
\   (
\       <SID>translate_mapping
\       (
\             g:translate_shell_mapping_configuration
\           , "<C-R>=expand("<cword>")<CR>"
\           , g:translate_shell_language
\           , "--verbose"
\       )
\       , g:translate_shell_mapping_configuration.window_position
\   )
\   <CR>

xnoremap <silent> <Plug>(translate-shell-selection-verbose-echo)
\   :<C-U>
\   call <SID>echo
\   (
\       <SID>translate_mapping
\       (
\             g:translate_shell_mapping_configuration
\           , <SID>selected_text()
\           , g:translate_shell_language
\           , "--verbose"
\       )
\   )
\   <CR>

xnoremap <silent> <Plug>(translate-shell-selection-verbose-window)
\   :<C-U>
\   call <SID>window
\   (
\       <SID>translate_mapping
\       (
\             g:translate_shell_mapping_configuration
\           , <SID>selected_text()
\           , g:translate_shell_language
\           , "--verbose"
\       ),
\       g:translate_shell_mapping_configuration.window_position
\   )
\   <CR>


if g:translate_shell_mappings_enabled == 1
    nnoremap mtw        <Plug>(translate-shell-word-brief-echo)
    nnoremap mtW        <Plug>(translate-shell-word-brief-window)
    xnoremap mtw        <Plug>(translate-shell-selection-brief-echo)
    xnoremap mtW        <Plug>(translate-shell-selection-brief-window)

    nnoremap mtv        <Plug>(translate-shell-word-verbose-echo)
    nnoremap mtV        <Plug>(translate-shell-word-verbose-window)
    xnoremap mtv        <Plug>(translate-shell-selection-verbose-echo)
    xnoremap mtV        <Plug>(translate-shell-selection-verbose-window)
endif


" --------------------------------------------------------------- commands -----
function! s:translate_command(args)
    let command = g:translate_shell_binary . " --no-ansi"

    for arg in a:args
        let command .= " " . arg
    endfor

    return systemlist(command)
endfunction


function! s:translate_command_dispatch(bang, mods, ...)
    if a:bang == "!"
        let mode = "horizontal"

        if (a:mods == "vertical") || (a:mods == "tab")
            let mode = a:mods
        endif

        :call <SID>window(<SID>translate_command(a:000), mode)
    else
        :call <SID>echo(<SID>translate_command(a:000))
    endif
endfunction


command! -nargs=+ -bang TS
\ :call <SID>translate_command_dispatch("<bang>", "<mods>", <f-args>)
