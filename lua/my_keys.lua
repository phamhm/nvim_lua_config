local telescopeBuiltin = require('telescope.builtin')
 
-- start key maps
vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, {})
vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, {})
vim.keymap.set('n', '<leader>fh', telescopeBuiltin.command_history, {})
vim.keymap.set('n', '<leader>fd', telescopeBuiltin.diagnostics, {})
vim.keymap.set('n', '<leader>q', ":bd<CR>", {})
vim.keymap.set('n', '<leader>w', ":w<CR>", {})
vim.keymap.set('n', '<leader>vn', ":vnew<CR>", {})
vim.keymap.set('n', 'j', "gj", {silent=true})
vim.keymap.set('n', 'k', "gk", {silent=true})
vim.keymap.set('n', '1', ":only<CR>",{})
vim.keymap.set('n', '2', ":vsp<CR>",{})
vim.keymap.set('n', '<leader>0', ":clo<CR>",{})
vim.keymap.set('n', '<leader>e', ":vsp<CR>:e .<CR>",{})
-- end key maps
--
require('myoptions')
