vim.keymap.set('n', '<leader>q', ":bd<CR>", {})
vim.keymap.set('n', '<leader>vn', ":vnew<CR>", {})
vim.keymap.set('n', 'j', "gj", {silent=true})
vim.keymap.set('n', 'k', "gk", {silent=true})

vim.keymap.set('n', '<leader>1', ":only<CR>",{})
vim.keymap.set('n', '<leader>2', ":vsp<CR>",{})
vim.keymap.set('n', '<leader>3', ":sp<CR>",{})
vim.keymap.set('n', '<leader>0', ":clo<CR>",{})

vim.keymap.set({'n', 'i'}, '<C-s>', "<Esc>:w<CR>",{silent = true})
--vim.keymap.set('i', '<C-j>', "<CR>",{silent = true})
vim.keymap.set('n', '<F3>', "Go<C-R><C-c>## <C-R>=strftime(\"%Y-%m-%d %a %I:%M %p\")<CR><Esc>o - Idea:<CR>- Thought:<Esc>kA",{})
vim.keymap.set('i', '<F3>', "<Esc>0Di## <C-R>=strftime(\"%Y-%m-%d %a %I:%M %p\")<CR><Esc>o- Idea:<CR>- Thought:<Esc>kA",{})

-- vim.keymap.set('n', '<leader>mt', ":MarkdownPreviewToggle<CR>",{silent = true})
--

vim.keymap.set('n', '<C-h>', "<C-w>h",{})
vim.keymap.set('n', '<C-j>', "<C-w>j",{})
vim.keymap.set('n', '<C-k>', "<C-w>k",{})
vim.keymap.set('n', '<C-l>', "<C-w>l",{})

vim.keymap.set('n', '<leader>hv', ":wincmd H | :vert resize 90<CR>",{silent = true})

-- end key maps
--

vim.keymap.set("n", "<leader>vt", ":e ~/Documents/vimwiki/trade_journal.md<CR>Gzt", { noremap = true, silent = true, desc = "Open init.lua" })

--vim.keymap.set("i", "<C-f>", "<C-c><Plug>(easymotion-w)", { noremap = true, silent = true, desc = "Open init.lua" })
--vim.keymap.set("i", "<C-b>", "<C-c><Plug>(easymotion-b)", { noremap = true, silent = true, desc = "Open init.lua" })
vim.keymap.set('n', '<leader><leader>l', '<Plug>(easymotion-wl)', { desc = 'EasyMotion move right on line' })
vim.keymap.set('n', '<leader><leader>h', '<Plug>(easymotion-bl)', { desc = 'EasyMotion move left on line' })

vim.keymap.set('i', '<C-j>', '<CR>', { remap = true })

vim.keymap.set('i', '<C-l>', '<Del>', { noremap = true, silent = true })

-- Bringing the whole line up or down
-- Normal mode
local move_line_down = "<C-M-j>"
local move_line_up = "<C-M-k>"
vim.keymap.set('n', move_line_down, ':m .+1<CR>==', { silent = true })
vim.keymap.set('i', move_line_down, '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('v', move_line_down, ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('n', move_line_up, ':m .-2<CR>==', { silent = true })
vim.keymap.set('i', move_line_up, '<Esc>:m .-2<CR>==gi', { silent = true })
vim.keymap.set('v', move_line_up, ":m '<-2<CR>gv=gv", { silent = true })

vim.keymap.set("v", "<leader>td", ":'<,'>m ?TODO? <CR>")
vim.keymap.set("n", "<leader>td", ":m ?TODO? <CR>")

vim.keymap.set({ "i", "v", "n", "s" }, "<C-c>", "<Esc>:noh<CR>" , {noremap = true})

vim.keymap.set("n", "<leader>hw", ":term curl 'wttr.in' <CR>", {silent = true})

-- shortcut to google
local google_shortcut ="<leader>gg"
local google_prompt = "Google: "
local opts = { noremap=true, silient=true}

local function google_search(input)
    if input and input ~="" then
        local query = vim.uri_encode(input)
        vim.ui.open("https://www.google.com/search?q=" .. query)
    end
end

vim.keymap.set("n", google_shortcut, function()
    vim.ui.input( { prompt = google_prompt}, google_search)
end, opt)

vim.keymap.set("v", google_shortcut, function()
   vim.cmd('noautocmd normal! "vy') -- yank selected into register v

   local selected_text = vim.fn.getreg('v')

   vim.ui.input({
       prompt = google_prompt,
       default = selected_text,
     },
   google_search)
end, opt)
-- end googling, }

-- capture

vim.keymap.set('n', '<leader>gc', function()
  vim.ui.input({ prompt = 'Text to append: ' }, function(input)
    if input and input ~= '' then
      vim.fn.writefile({ "- " .. input }, vim.fn.expand("~/Documents/vimwiki/daily_reminder.md"), "a")
    end
  end)
end, { desc = 'Ask for text and append to end of file' })

-- end capture

-- Open mini.files at the current working directory (CWD)
vim.keymap.set('n', '<C-e>', function()
  require('mini.files').open()
end, { desc = 'Open mini.files (Root)' })

vim.keymap.set("n", "<leader>c<space>", "gcc", {remap = true, silent=true, desc = "toggle comment"})
vim.keymap.set("v", "<leader>c<space>", "gc", {remap = true, silent=true, desc = "toggle comment"})
