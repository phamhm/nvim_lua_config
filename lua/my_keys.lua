local telescopeBuiltin = require('telescope.builtin')
local actions = require('telescope.actions')
local layout_actions = require('telescope.actions.layout')

require('telescope').setup({
  defaults = {
      mappings = {
          n = {
              -- Toggle preview with 'p' in normal mode
              ['p'] = layout_actions.toggle_preview,
              ["<C-j>"] = actions.preview_scrolling_down,
              ["<C-k>"] = actions.preview_scrolling_up,
              --["<C-h>"] = actions.preview_scrolling_left, -- Alternative
              --["<C-l>"] = actions.preview_scrolling_right,   -- Alternative
          },
          i = { -- Insert mode mappings
          },
      },
      layout_strategy = 'horizontal',
      layout_config = {
          horizontal = {
              width = 0.50,     -- 90% of screen width
              height = 0.50,    -- 85% of screen height
              preview_width = 0.6, -- 60% for the preview window
          },
      },
  },
})

-- start key maps
vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, {})
vim.keymap.set('n', '<leader>gf', telescopeBuiltin.git_files, {})
vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, {})
vim.keymap.set('n', '<leader>fh', telescopeBuiltin.command_history, {})
vim.keymap.set('n', '<leader>fj', telescopeBuiltin.jumplist, {})
vim.keymap.set('n', '<leader>fk', telescopeBuiltin.keymaps, {})
vim.keymap.set('n', '<leader>fd', telescopeBuiltin.diagnostics, {})
vim.keymap.set('n', '<leader>fc', telescopeBuiltin.commands, {})
vim.keymap.set('n', '<leader>fl', telescopeBuiltin.loclist, {})
vim.keymap.set('n', '<leader>fq', telescopeBuiltin.quickfix, {})
vim.keymap.set('n', '<leader>fo', telescopeBuiltin.oldfiles, {})
vim.keymap.set('n', '<leader>fm', telescopeBuiltin.marks, {})
vim.keymap.set('n', '<leader>fr', telescopeBuiltin.registers, {})
vim.keymap.set('n', '<leader>f/', telescopeBuiltin.current_buffer_fuzzy_find, {})
vim.keymap.set('n', '<C-p>', telescopeBuiltin.commands, {})

-- git fugitive

vim.keymap.set('n', '<leader>gg', ":Git<CR>", {})
vim.keymap.set('n', '<leader>gp', ":Git push<CR>", {})
-- end git fugitive

vim.keymap.set('n', '<leader>q', ":bd<CR>", {})
vim.keymap.set('n', '<leader>vn', ":vnew<CR>", {})
vim.keymap.set('n', 'j', "gj", {silent=true})
vim.keymap.set('n', 'k', "gk", {silent=true})

vim.keymap.set('n', '<leader>1', ":only<CR>",{})
vim.keymap.set('n', '<leader>2', ":vsp<CR>",{})
vim.keymap.set('n', '<leader>3', ":sp<CR>",{})
vim.keymap.set('n', '<leader>c', ":clo<CR>",{})
vim.keymap.set('n', '<leader>bp', ":bp<CR>",{})
vim.keymap.set('n', '<leader>bn', ":bn<CR>",{})

vim.keymap.set('n', '<leader>e', ":NERDTreeToggle<CR>",{})
vim.keymap.set('n', '<leader>.', ":noh<CR>",{silent = true})
vim.keymap.set('n', '<C-s>', ":w<CR>",{silent = true})
vim.keymap.set('i', '<C-s>', "<Esc>:w<CR>",{silent = true})
--vim.keymap.set('i', '<C-j>', "<CR>",{silent = true})
vim.keymap.set('i', '<C-k><C-s>', "<Esc>:w<Cr>",{})
vim.keymap.set('n', '<F3>', "Go<C-R><C-c>## <C-R>=strftime(\"%Y-%m-%d %a %I:%M %p\")<CR><Esc>o - Idea:<CR>- Thought:<Esc>kA",{})
vim.keymap.set('i', '<F3>', "<Esc>0Di## <C-R>=strftime(\"%Y-%m-%d %a %I:%M %p\")<CR><Esc>o- Idea:<CR>- Thought:<Esc>kA",{})

vim.keymap.set('n', '<leader>t', "Gzt",{silent = true})

vim.keymap.set('n', '<leader>mt', ":MarkdownPreviewToggle<CR>",{silent = true})
--

vim.keymap.set('n', '<C-h>', "<C-w>h",{})
vim.keymap.set('n', '<C-j>', "<C-w>j",{})
vim.keymap.set('n', '<C-k>', "<C-w>k",{})
vim.keymap.set('n', '<C-l>', "<C-w>l",{})

vim.keymap.set('n', '<leader>hv', ":wincmd H | :vert resize 90<CR>",{silent = true})

-- end key maps
--

local ls = require("luasnip")

--vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
--vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
--vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

--vim.keymap.set({"i", "s"}, "<C-E>", function()
	--if ls.choice_active() then
		--ls.change_choice(1)
	--end
--end, {silent = true})


vim.keymap.set("n", "<leader>vt", ":e ~/Documents/vimwiki/trade_journal.md<CR>Gzt", { noremap = true, silent = true, desc = "Open init.lua" })

--vim.keymap.set("i", "<C-f>", "<C-c><Plug>(easymotion-w)", { noremap = true, silent = true, desc = "Open init.lua" })
--vim.keymap.set("i", "<C-b>", "<C-c><Plug>(easymotion-b)", { noremap = true, silent = true, desc = "Open init.lua" })


vim.keymap.set('i', '<C-j>', '<CR>', { remap = true })


vim.keymap.set('i', '<C-l>', '<Del>', { noremap = true, silent = true })


-- Bringing the whole line up or down
-- Normal mode
vim.keymap.set('n', '<M-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<M-k>', ':m .-2<CR>==', { silent = true })

-- Insert mode
vim.keymap.set('i', '<M-j>', '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('i', '<M-k>', '<Esc>:m .-2<CR>==gi', { silent = true })

-- Visual mode
vim.keymap.set('v', '<M-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<M-k>', ":m '<-2<CR>gv=gv", { silent = true })
