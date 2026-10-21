local utils = require("utils.functions")
local alt_key = utils.format_os_altkey
local map = utils.map

vim.keymap.set(
  'n',
  "<leader>mk",
  function()
    local scratch = Snacks.scratch({
      ft = "text",
      name = "keys from utils.lua"
    })
    vim.api.nvim_buf_set_lines(0, 0, -1, false, utils.get_keys())
  end,
  {desc = "utils.keys"}
)

-- map('n', '<leader>vn', ":vnew<CR>", {})
map('n', alt_key('<%s-q>',2), ":qa!<CR>", {desc="force quit everything"})
map('n', alt_key('<%s-r>', 2), "<cmd>restart<CR>", {desc="restart nvim"})

map({ 'n', 'v' }, 'j', "gj", {silent=true, desc = "virtual line movement"})
map({ 'n', 'v' }, 'k', "gk", {silent=true, desc = "virtual line movement"})
map({ "n", "v" }, "0", "g0", {silent=true, desc = "virtual line movement"})
map({ "n", "v" }, "$", "g$", {silent=true, desc = "virtual line movement"})

map('n', '<leader>1', ":only<CR>",{desc = "only one window"})
map('n', '<leader>2', ":vsp<CR>",{desc = "vertical split"})
map('n', '<leader>3', ":sp<CR>",{desc = "horizontal split"})
map('n', '<leader>0', ":clo<CR>",{desc = "close this buffer :clo"})

map({'n', 'i', 'v'}, '<C-s>', "<cmd>w<cr>",{silent = true, desc="save buffer"})
map('i', '<C-j>', "<Esc>o",{silent = true, desc="in middle of line, and still new line"})

-- end key maps

--map("i", "<C-f>", "<C-c><Plug>(easymotion-w)", { noremap = true, silent = true, desc = "Open init.lua" })
--map("i", "<C-b>", "<C-c><Plug>(easymotion-b)", { noremap = true, silent = true, desc = "Open init.lua" })
map({'n', 'v'}, '<leader><leader>l', '<Plug>(easymotion-wl)', { desc = 'EasyMotion move right on line' })
map({'n', 'v'}, '<leader><leader>h', '<Plug>(easymotion-bl)', { desc = 'EasyMotion move left on line' })

-- c-h delete before cursor.
-- c-l delete after cursor.
-- balancing out the universe
map('i', '<C-l>', '<Del>', { noremap = true, silent = true, desc="delete next letter"})

-- Bringing the whole line up or down
-- Normal mode
map('n', alt_key("<C-%s-j>"), ':m .+1<CR>==', { silent = true, desc="move the whole block down" })
map('i', alt_key("<C-%s-j>"), '<Esc>:m .+1<CR>==gi', { silent = true, desc="move the whole block down" })
map('v', alt_key("<C-%s-j>"), ":m '>+1<CR>gv=gv", { silent = true, desc="move the whole block down" })
map('n', alt_key("<C-%s-k>"), ':m .-2<CR>==', { silent = true, desc="move the whole block up" })
map('i', alt_key("<C-%s-k>"), '<Esc>:m .-2<CR>==gi', { silent = true, desc="move the whole block up" })
map('v', alt_key("<C-%s-k>"), ":m '<-2<CR>gv=gv", { silent = true, desc="move the whole block up" })

-- simplify the capture. Don't need to move around.
-- keeps these here as example of moving with vim command
-- map("v", "<leader>td", ":'<,'>m ?^# Capture$?-2 <CR>")
-- map("n", "<leader>td", ":m ?^# Capture$?-2 <CR>")
-- map("v", "<leader>tc", ":'<,'>m /^# Capture$/ <CR>")
-- map("n", "<leader>tc", ":m /^# Capture$/ <CR>")

map({ "i", "v", "n", "s" }, "<C-c>", "<Esc>:noh<CR>" , {noremap = true, desc="Esc and call no highlight"})

-- shortcut to google
local function query(query_url)
  return function(input)
    if input and input ~="" then
      local query = vim.uri_encode(input)
      vim.ui.open(query_url .. query)
    end
  end
end

map("n", "<leader>gy", function()
  vim.ui.input( { prompt = "Youtube:"}, query("https://www.youtube.com/results?search_query="))
end, {desc="query youtube"})

local function google(prompt, default)
  vim.ui.input({
    prompt = prompt,
    default = default .. ' ',
  }, query("https://www.google.com/search?q="))
end

map("n", "<leader>gr", function()  google("Goog Reddit", "reddit") end, {desc="query youtube"})

map({"n","v" }, "<leader>gg", function()
  local current_mode = vim.fn.mode(1)
  local selected_text = ""
  if current_mode == "v" or current_mode ==  "V" then
    vim.cmd('noautocmd normal! "vy') -- yank selected into register v
    selected_text = vim.fn.getreg('v'):gsub("\r?\n", "")
  end

  google("Google", selected_text)
end, {desc="googling google"})
-- end googling, }

-- capture
map('n', '<leader>cc', function()
  vim.ui.input({ prompt = 'Capture: ' }, utils.write_note )
end, { desc = 'Capture text and apped to working_notes.md' })

map('n', '<leader>bb', function()
  local reg_p = vim.trim(vim.fn.getreg('*'))
  if reg_p == "" or not vim.startswith(reg_p, "http") then
    vim.notify("Register @* isn't an url:'"..reg_p.."'", vim.log.levels.ERROR)
    return
  end
  vim.notify("Bookmarking:" .. reg_p)
  vim.ui.input({ prompt = string.sub(reg_p,1, 50) }, function(input)
    local note_text = "[" .. input .. "](" .. reg_p .. ")"
    utils.write_note(note_text)
  end)
end, {silent = true, desc = 'Capture url/bookmarking to working_notes.md' })

map('n', '<leader>vd',
  function()
    local today_date = os.date('%Y-%m-%d')
    local file_path = vim.g.m_notes_path .. "/diary/" .. today_date .. ".md"
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
  end, { desc = 'Capture to today diary file' })

-- end capture

map("n", "<leader>c<space>", "gcc", {remap = true, silent=true, desc = "toggle comment"})
map("v", "<leader>c<space>", "gc", {remap = true, silent=true, desc = "toggle comment"})


map("v", "Y", function()
  vim.cmd.normal([["+y]])
  vim.cmd.normal([["*y]])
  local reg = vim.fn.getreg('+')
  vim.notify("@+="..reg)
end, {desc = "yank virtual into system clipboard"})

map("n", "<leader>p", '"*p', {desc="paste @* clipboard", remap=false})

-- use Mini.Files locate the file under cursor.
map('n', '<leader>gf', function()
  -- Get the file path under the cursor using Neovim's built-in <cfile>
  local target = vim.fn.expand('<cfile>')

  -- Fallback to the current buffer's directory if <cfile> is empty
  if target == "" then
    MiniFiles.open(vim.api.nvim_buf_get_name(0))
    return
  end

  -- Resolve full path relative to current working directory if it's not absolute
  local full_path = vim.fn.fnamemodify(target, ':p')

  -- Check if the target is a directory or a file
  if vim.fn.isdirectory(full_path) == 1 then
    MiniFiles.open(full_path)
  else
    -- If it's a file, get its parent directory
    local dir = vim.fn.fnamemodify(full_path, ':h')
    MiniFiles.open(dir)
  end
end, { desc = "Open MiniFiles in directory of file under cursor" })

vim.keymap.set('n', '<leader><leader>o', function()
  vim.ui.open(vim.fn.expand('%'))
end, { desc = 'Open current buffer with system handler' })


-- how to define this but ignore minifiles
map('n', "<C-d>", '<C-d>zz', { desc = "half page down, centered" })
map('n', "<C-u>", '<C-u>zz', { desc = "half page up, centered" })

map('n', "G", function() vim.cmd("normal! G") vim.cmd("normal! zz") end, { desc = "up, centered" })
