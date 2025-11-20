" vim-translate-shell - Translate text using translate-shell application
"
" Author:     Artur Pyszczuk <apyszczuk@gmail.com>
" License:    Same terms as Vim itself
" Website:    https://github.com/apyszczuk/vim-translate-shell

if exists ('g:loaded_translate_shell')
    finish
endif
let g:loaded_translate_shell = 1



let g:translate_shell_mappings_enabled      = 1
let s:translate_shell_binary                = "trans"

let g:translate_shell_verbose =
\ {
\     "--no-ansi"                           : ""
\ }

let g:translate_shell_brief =
\ {
\     "-brief"                              : ""
\   , "--no-ansi"                           : ""
\ }

let g:translate_shell_language =
\ {
\     "source"                              : ""
\   , "target"                              : "pl"
\ }

let g:translate_shell_configuration =
\ {
\     "group_paragraphs"                    : 1
\   , "min_width_for_reformat"              : 40
\   , "window_split_direction"              : "vertical" 
\ }





function! s:get_selection()
    let tmp = @a

    :silent normal! gv"ay
    let ret = @a
    let @a = tmp

    return ret
endfunction

function! s:max_width(lst)
    let i   = 0
    let ret = 0

    " echo "len(lst) = " . len(a:lst)

    while i < len(a:lst)
        let sz = len(a:lst[i])
        " echo sz

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

    " echo "source"
    " echo a:source

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

function! s:translate(content, language, options, configuration)
    let content_list    = split(a:content, "\n")
    let paragraphs      = a:configuration.group_paragraphs ?
    \                     s:single_line_paragraphs(content_list) :
    \                     content_list
    let max_width       = s:max_width(content_list)
    " echo "max_width = " . max_width


    let command = s:translate_shell_binary

    " languages
    let command .= " " . a:language.source . ":" . a:language.target


    " flags / options-values
    for option_key in keys(a:options)
        let option_value = a:options[option_key]

        let command .= " " . option_key
        if len(option_value) > 0
            let command .= " " . option_value
        endif
    endfor


    " content
    let content_string = ""
    for paragraph in paragraphs
        let content_string .= paragraph . "\n"
    endfor

    let content_string = escape(content_string, '"')
    let content_string = trim(content_string)

    let command .= " " . '"' . content_string . '"'


    " echo command
    " formatter
    " conditional because source text can be very short
    " and translation can be longer, which can wrap to
    " two or more lines, which is a little bit weird.
    if max_width > a:configuration.min_width_for_reformat
        let command .= " | fmt -w " . max_width
    endif


    " execute command
    return systemlist(command)
endfunction


function! s:echo(translation)
    echo join(a:translation, "\n")
endfunction

function! s:window(translation, configuration)
    execute ":" a:configuration.window_split_direction . " new " . tempname()
    call append(0, a:translation)
    :write

    setlocal bufhidden=delete
    setlocal nomodifiable
endfunction



nnoremap <silent> <Plug>(translate-shell-word-brief-echo)
\   :call <SID>echo
\   (
\       <SID>translate
\       (
\           "<C-R>=expand("<cword>")<CR>",
\           g:translate_shell_language,
\           g:translate_shell_brief,
\           g:translate_shell_configuration
\       )
\   )
\   <CR>

xnoremap <silent> <Plug>(translate-shell-selection-brief-echo)
\   :<C-U>
\   call <SID>echo
\   (
\       <SID>translate
\       (
\           <SID>get_selection(),
\           g:translate_shell_language,
\           g:translate_shell_brief,
\           g:translate_shell_configuration
\       )
\   )
\   <CR>

xnoremap <silent> <Plug>(translate-shell-selection-brief-window)
\   :<C-U>
\   call <SID>window
\   (
\       <SID>translate
\       (
\           <SID>get_selection(),
\           g:translate_shell_language,
\           g:translate_shell_brief,
\           g:translate_shell_configuration
\       ),
\       g:translate_shell_configuration
\   )
\   <CR>


nnoremap <silent> <Plug>(translate-shell-word-verbose-echo)
\   :call <SID>echo
\   (
\       <SID>translate
\       (
\           "<C-R>=expand("<cword>")<CR>",
\           g:translate_shell_language,
\           g:translate_shell_verbose,
\           g:translate_shell_configuration
\       )
\   )
\   <CR>

xnoremap <silent> <Plug>(translate-shell-selection-verbose-echo)
\   :<C-U>
\   call <SID>echo
\   (
\       <SID>translate
\       (
\           <SID>get_selection(),
\           g:translate_shell_language,
\           g:translate_shell_verbose,
\           g:translate_shell_configuration
\       )
\   )
\   <CR>

xnoremap <silent> <Plug>(translate-shell-selection-verbose-window)
\   :<C-U>
\   call <SID>window
\   (
\       <SID>translate
\       (
\           <SID>get_selection(),
\           g:translate_shell_language,
\           g:translate_shell_verbose,
\           g:translate_shell_configuration
\       ),
\       g:translate_shell_configuration
\   )
\   <CR>


if g:translate_shell_mappings_enabled == 1
    nnoremap mtw        <Plug>(translate-shell-word-brief-echo)
    xnoremap mtw        <Plug>(translate-shell-selection-brief-echo)
    xnoremap mtW        <Plug>(translate-shell-selection-brief-window)

    nnoremap mtv        <Plug>(translate-shell-word-verbose-echo)
    xnoremap mtv        <Plug>(translate-shell-selection-verbose-echo)
    xnoremap mtV        <Plug>(translate-shell-selection-verbose-window)
endif
