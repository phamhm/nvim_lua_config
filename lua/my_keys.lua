local telescopeBuiltin = require('telescope.builtin')
 
-- start key maps
vim.keymap.set('n', '<leader>ff', telescopeBuiltin.git_files, {})
vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, {})
vim.keymap.set('n', '<leader>fh', telescopeBuiltin.command_history, {})
vim.keymap.set('n', '<leader>fd', telescopeBuiltin.diagnostics, {})
vim.keymap.set('n', '<leader>fc', telescopeBuiltin.commands, {})
vim.keymap.set('n', '<leader>fq', telescopeBuiltin.quickfix, {})
vim.keymap.set('n', '<leader>fo', telescopeBuiltin.oldfiles, {})
vim.keymap.set('n', '<leader>fm', telescopeBuiltin.marks, {})
vim.keymap.set('n', '<leader>fr', telescopeBuiltin.registers, {})
vim.keymap.set('n', '<leader>f/', telescopeBuiltin.current_buffer_fuzzy_find, {})

-- git fugitive

vim.keymap.set('n', '<leader>gg', ":Git<CR>", {})
vim.keymap.set('n', '<leader>gp', ":Git push<CR>", {})
-- end git fugitive

vim.keymap.set('n', '<leader>q', ":bd<CR>", {})
vim.keymap.set('n', '<leader>0', ":clo<CR>",{})
vim.keymap.set('n', '<leader>vn', ":vnew<CR>", {})
vim.keymap.set('n', 'j', "gj", {silent=true})
vim.keymap.set('n', 'k', "gk", {silent=true})

vim.keymap.set('n', '<leader>1', ":only<CR>",{})
vim.keymap.set('n', '<leader>2', ":vsp<CR>",{})
vim.keymap.set('n', '<leader>3', ":sp<CR>",{})
vim.keymap.set('n', '<leader>bp', ":bp<CR>",{})
vim.keymap.set('n', '<leader>bn', ":bn<CR>",{})

vim.keymap.set('n', '<leader>e', ":NERDTreeExplore<CR>",{})
vim.keymap.set('n', ';.', ":noh<CR>",{silent = true})
vim.keymap.set('n', '<C-s>', ":w<CR>",{silent = true})
vim.keymap.set('i', '<C-s>', "<Esc>:w<CR>",{silent = true})
vim.keymap.set('i', '<C-c>', "<Esc>:noh<CR>",{silent = true})
vim.keymap.set('n', '<C-c>', "<Esc>:noh<CR>",{silent = true})


-- quickfix list nav
vim.keymap.set('n', '<M-p>', "<Esc>:cprev<CR>",{silent = true})
vim.keymap.set('n', '<M-n>', "<Esc>:cnext<CR>",{silent = true})
vim.keymap.set('n', '<M-o>', "<Esc>:copen<CR>",{silent = true})
vim.keymap.set('n', '<M-c>', "<Esc>:cclose<CR>",{silent = true})
-- end quickfix list nav




-- end key maps
