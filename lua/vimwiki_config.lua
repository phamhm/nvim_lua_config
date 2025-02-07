--vim.cmd [[
--let g:vimwiki_listsyms = '.○◐●✓'
--let g:vimwiki_folding='expr'
--let wiki = {}
--let wiki.path = 'C:\Users\phamh\Dropbox\vimwiki'
--let wiki.syntax = 'markdown'
--let wiki.ext = '.md'
--let wiki.nested_syntax = {'python':'python', 'rust':'rust', 'c++':'cpp', 'c':'c'}
--let g:vimwiki_list = [wiki]
--map <F1> :VimwikiIndex<CR>
--imap <F1> :VimwikiIndex<CR>
--nnoremap <leader>it :pu=strftime('%a %m-%d-%Y')<Enter>
--]]


vim.cmd [[

let wiki = {}
let wiki.nested_syntaxes = {'python':'python', 'rust':'rust', 'c++':'cpp', 'c':'c'}

let g:vimwiki_list = [wiki]

hi VimwikiLink term=italic gui=bold,italic

augroup Mkd
    au BufRead,BufWinEnter,BufNewFile *.{md,mdx,mdown,mkd,mkdn,markdown,mdwn} setlocal syntax=markdown
    au BufRead,BufWinEnter,BufNewFile *.{md,mdx,mdown,mkd,mkdn,markdown,mdwn}.{des3,des,bf,bfa,aes,idea,cast,rc2,rc4,rc5,desx} setlocal syntax=markdown
augroup END
]]


