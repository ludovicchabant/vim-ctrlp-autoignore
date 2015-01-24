" =============================================================================
" File:          autoload/ctrlp/autoignore.vim
" Description:   Auto-ignore Extension
" Author:        Ludovic Chabant <github.com/ludovicchabant>
" =============================================================================


" Global Settings {{{

if !exists('g:ctrlp_autoignore_debug')
    let g:ctrlp_autoignore_debug = 0
endif

if !exists('g:ctrlp_autoignore_trace')
    let g:ctrlp_autoignore_trace = 0
endif

if exists('g:ctrlp_autoignore_loaded') && g:ctrlp_autoignore_loaded
            \ && !g:ctrlp_autoignore_debug
    finish
endif
let g:ctrlp_autoignore_loaded = 1

" }}}

" Initialization {{{

if !exists('g:ctrlp_custom_ignore')
    let g:ctrlp_custom_ignore = {}
endif
let g:ctrlp_custom_ignore['func'] = 'ctrlp#autoignore#ignore'
let g:ctrlp_custom_ignore['func-init'] = 'ctrlp#autoignore#ignore_init'

" }}}

" Internals {{{

function! s:trace(message) abort
    if g:ctrlp_autoignore_trace
        echom "ctrlp_autoignore: " . a:message
    endif
endfunction

let s:proj_cache = {}
let s:active_patterns = []

function! s:load_project_patterns(root_dir) abort
    let l:ign_path = a:root_dir . '/.ctrlpignore'
    if !filereadable(l:ign_path)
        call s:trace("No pattern file at: " . l:ign_path)
        return []
    endif
    let l:patterns = []
    let l:lines = readfile(l:ign_path)
    for line in l:lines
        if match(line, '\v^\s*$') >= 0 || match(line, '\v^\s*#') >= 0
            continue
        endif
        let l:matches = matchlist(line, '\v^((dir|file|link)\:)?(.*)')
        let l:mtype = l:matches[2]
        let l:mpat = l:matches[3]
        call add(l:patterns, {'type': l:mtype, 'pat': l:mpat})
    endfor
    call s:trace("Loaded " . len(l:patterns) . " patterns from: " . l:ign_path)
    return l:patterns
endfunction

function! s:get_project_patterns(root_dir) abort
    let l:patterns = get(s:proj_cache, a:root_dir)
    if type(l:patterns) == type([])
        return l:patterns
    endif

    call s:trace("Loading patterns for project: " . a:root_dir)
    let l:loaded = s:load_project_patterns(a:root_dir)
    let s:proj_cache[a:root_dir] = l:loaded
    return l:loaded
endfunction

" The custom ignore function that CtrlP will be using in addition to
" normal pattern-based matching.
function! ctrlp#autoignore#ignore(item, type) abort
    for pat in s:active_patterns
        if pat['type'] == '' || pat['type'] == a:type
            let l:cnv_item = tr(a:item, "\\", "/")
            if match(l:cnv_item, pat['pat']) >= 0
                return 1
            endif
        endif
    endfor
    return 0
endfunction

function! ctrlp#autoignore#ignore_init() abort
    let l:root = getcwd()
    let s:active_patterns = s:get_project_patterns(l:root)
endfunction

" List patterns for a given project's root.
function! ctrlp#autoignore#get_patterns(root_dir) abort
    let l:patterns = s:get_project_patterns(a:root_dir)
    for pat in l:patterns
        let l:prefix = pat['type'] == '' ? '(all)' : pat['type']
        echom l:prefix . ':' . pat['pat']
    endfor
endfunction

" }}}

