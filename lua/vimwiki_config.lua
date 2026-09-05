vim.cmd [[
    let wiki = {}
    let wiki.nested_syntaxes = {'python':'python', 'rust':'rust', 'c++':'cpp', 'c':'c'}

    map <F1> :VimwikiIndex<CR>

    let g:vimwiki_list = [wiki]

    hi @markup.link term=italic ctermfg=cyan guifg=cyan gui=italic
    hi mkdLink term=italic ctermfg=grey guifg=grey gui=italic


    augroup Mkd
    au BufRead,BufWinEnter,BufNewFile *.{md,mdx,mdown,mkd,mkdn,markdown,mdwn} setlocal syntax=markdown
    au BufRead,BufWinEnter,BufNewFile *.{md,mdx,mdown,mkd,mkdn,markdown,mdwn} setlocal nospell
    au BufRead,BufWinEnter,BufNewFile *.{md,mdx,mdown,mkd,mkdn,markdown,mdwn}.{des3,des,bf,bfa,aes,idea,cast,rc2,rc4,rc5,desx} setlocal syntax=markdown
    augroup END
]]


