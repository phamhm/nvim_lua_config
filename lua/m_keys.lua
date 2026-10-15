local map = vim.keymap.set

map('n', '<C-q><C-q><C-q>', ":q!<CR>", {})
map('n', '<leader>vn', ":vnew<CR>", {})
map('n', 'j', "gj", {silent=true})
map('n', 'k', "gk", {silent=true})

map('n', '<leader>1', ":only<CR>",{})
map('n', '<leader>2', ":vsp<CR>",{})
map('n', '<leader>3', ":sp<CR>",{})
map('n', '<leader>0', ":clo<CR>",{})

map({'n', 'i'}, '<C-s>', "<Esc>:w<CR>",{silent = true})
map('i', '<C-j>', "<Esc>o",{silent = true})
map('i', '<C-a>', "<Esc>A",{silent = true})
map('n', '<F3>', "Go<C-R><C-c>## <C-R>=strftime(\"%Y-%m-%d %a %I:%M %p\")<CR><Esc>o - Idea:<CR>- Thought:<Esc>kA",{})
map('i', '<F3>', "<Esc>0Di## <C-R>=strftime(\"%Y-%m-%d %a %I:%M %p\")<CR><Esc>o- Idea:<CR>- Thought:<Esc>kA",{})

-- map('n', '<leader>mt', ":MarkdownPreviewToggle<CR>",{silent = true})

-- end key maps
--

--map("i", "<C-f>", "<C-c><Plug>(easymotion-w)", { noremap = true, silent = true, desc = "Open init.lua" })
--map("i", "<C-b>", "<C-c><Plug>(easymotion-b)", { noremap = true, silent = true, desc = "Open init.lua" })
map({'n', 'v'}, '<leader><leader>l', '<Plug>(easymotion-wl)', { desc = 'EasyMotion move right on line' })
map({'n', 'v'}, '<leader><leader>h', '<Plug>(easymotion-bl)', { desc = 'EasyMotion move left on line' })

-- c-h delete before cursor.
-- c-l delete after cursor.
-- balancing out the universe
map('i', '<C-l>', '<Del>', { noremap = true, silent = true })

-- Bringing the whole line up or down
-- Normal mode
local move_line_prefix = "C-M"
map('n', '<' .. move_line_prefix .. '-j>', ':m .+1<CR>==', { silent = true })
map('i', '<' .. move_line_prefix .. '-j>', '<Esc>:m .+1<CR>==gi', { silent = true })
map('v', '<' .. move_line_prefix .. '-j>', ":m '>+1<CR>gv=gv", { silent = true })
map('n', '<' .. move_line_prefix .. '-k>', ':m .-2<CR>==', { silent = true })
map('i', '<' .. move_line_prefix .. '-k>', '<Esc>:m .-2<CR>==gi', { silent = true })
map('v', '<' .. move_line_prefix .. '-k>', ":m '<-2<CR>gv=gv", { silent = true })

-- simplify the capture. Don't need to move around.
-- keeps these here as example of moving with vim command
-- map("v", "<leader>td", ":'<,'>m ?^# Capture$?-2 <CR>")
-- map("n", "<leader>td", ":m ?^# Capture$?-2 <CR>")
-- map("v", "<leader>tc", ":'<,'>m /^# Capture$/ <CR>")
-- map("n", "<leader>tc", ":m /^# Capture$/ <CR>")

map({ "i", "v", "n", "s" }, "<C-c>", "<Esc>:noh<CR>" , {noremap = true})

-- shortcut to google
local google_shortcut ="<leader>gg"
local google_prompt = "Google: "

local function google_search(input)
  if input and input ~="" then
    local query = vim.uri_encode(input)
    vim.ui.open("https://www.google.com/search?q=" .. query)
  end
end

map("n", google_shortcut, function()
  vim.ui.input( { prompt = google_prompt}, google_search)
end, opt)

map("v", google_shortcut, function()
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

map('n', '<leader>gc', function()
  vim.ui.input({ prompt = 'Capture: ' }, function(input)
    if input and input ~= '' then
      local today_date = os.date('%Y-%m-%d')
      vim.fn.writefile({ "[".. today_date .."] " .. input }, vim.fn.expand(vim.g.m_vimwiki_path .. "/daily_reminder.md"), "a")
    end
  end)
end, { desc = 'Ask for text and append to end of file' })

map('n', '<leader>gb', function()
  local reg_p = vim.fn.getreg('+')
  vim.notify("Bookmarking:" .. reg_p)
  vim.ui.input({ prompt = string.sub(reg_p,1, 50) }, function(input)
    if input and input ~= '' and reg_p and reg_p ~='' then
      vim.fn.writefile({ "[" .. input .. "](" .. reg_p .. ")"  }, vim.fn.expand(vim.g.m_vimwiki_path .. "/bookmarks.md"), "a")
    end
  end)
end, {silent = true, desc = 'Ask for text and append to end of file' })

map('n', '<leader>vd',
  function()
    local today_date = os.date('%Y-%m-%d')
    local file_path = vim.g.m_vimwiki_path .. "/diary/" .. today_date .. ".md"
    file_path = vim.fn.expand(file_path)
    vim.ui.input({ prompt = "Today Diary Entry:"}, function(content)
      local file = io.open(file_path, "a")
      if file then
        file:write("- " .. content .. '\n')
        file:close()
        print("Saved to " .. file_path)
      else
        vim.notify("Error: could not write diary entry", vim.log.levels.ERROR)
      end
    end)
  end, { desc = 'Ask for text and append to end of file' })

-- end capture

map("n", "<leader>c<space>", "gcc", {remap = true, silent=true, desc = "toggle comment"})
map("v", "<leader>c<space>", "gc", {remap = true, silent=true, desc = "toggle comment"})


map('n', "<leader>cc", function()
  local reg = vim.fn.getreg('"')
  vim.fn.setreg("+", reg)
  vim.notify('Copied @" into system clipboard @+:'..reg)
end, {desc = 'copy yanked @" into system clipboard @+'})
map('i', "<D-v>", '<Esc>"*pa', {desc = 'paste from @* register '})

map("v", "Y", '"*y', {desc = "yank virtual into system clipboard"})
