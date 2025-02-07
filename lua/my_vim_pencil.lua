vim.g["pencil#wrapModeDefault"] = "soft"
vim.g["pencil#autoformat"] = 1
vim.g["pencil#textwidth"] = 72

vim.cmd([[

let g:pencil#mode_indicators = {'hard': 'H', 'auto': 'A', 'soft': 'S', 'off': '',}

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd,txt call pencil#init()
                                \ | call lexical#init()
                                \ | call litecorrect#init()
                                \ | call textobj#sentence#init()
augroup END

]])

--[[
--]]

