local utils = require("utils.functions")

local map = vim.keymap.set

-- map('n', '<leader>vn', ":vnew<CR>", {})
map('n', '<C-q><C-q><C-q>', ":qa!<CR>", {})
map({ 'n', 'v' }, 'j', "gj", {silent=true})
map({ 'n', 'v' }, 'k', "gk", {silent=true})
map({ "n", "v" }, "0", "g0", {silent=true})
map({ "n", "v" }, "$", "g$", {silent=true})

map('n', '<leader>1', ":only<CR>",{})
map('n', '<leader>2', ":vsp<CR>",{})
map('n', '<leader>3', ":sp<CR>",{})
map('n', '<leader>0', ":clo<CR>",{})

map({'n', 'i', 'v'}, '<C-s>', "<Esc>:w<CR>",{silent = true})
map('i', '<C-j>', "<Esc>o",{silent = true})
map('i', '<C-a>', "<Esc>A",{silent = true})

-- end key maps

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
local move_line_prefix = vim.uv.os_uname().sysname == "Darwin" and "C-D" or "C-M"
map('n', utils.format_os_altkey("<C-%s-j>"), ':m .+1<CR>==', { silent = true })
map('i', utils.format_os_altkey("<C-%s-j>"), '<Esc>:m .+1<CR>==gi', { silent = true })
map('v', utils.format_os_altkey("<C-%s-j>"), ":m '>+1<CR>gv=gv", { silent = true })
map('n', utils.format_os_altkey("<C-%s-k>"), ':m .-2<CR>==', { silent = true })
map('i', utils.format_os_altkey("<C-%s-k>"), '<Esc>:m .-2<CR>==gi', { silent = true })
map('v', utils.format_os_altkey("<C-%s-k>"), ":m '<-2<CR>gv=gv", { silent = true })

-- simplify the capture. Don't need to move around.
-- keeps these here as example of moving with vim command
-- map("v", "<leader>td", ":'<,'>m ?^# Capture$?-2 <CR>")
-- map("n", "<leader>td", ":m ?^# Capture$?-2 <CR>")
-- map("v", "<leader>tc", ":'<,'>m /^# Capture$/ <CR>")
-- map("n", "<leader>tc", ":m /^# Capture$/ <CR>")

map({ "i", "v", "n", "s" }, "<C-c>", "<Esc>:noh<CR>" , {noremap = true})

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
  vim.ui.input( { prompt = "Youtube:"},query("https://www.youtube.com/results?search_query="))
end, opt)

map({"n","v" }, "<leader>gg", function()
  local current_mode = vim.fn.mode(1)
  local selected_text = ""
  if current_mode == "v" or current_mode ==  "V" then
    vim.cmd('noautocmd normal! "vy') -- yank selected into register v
    selected_text = vim.fn.getreg('v')
  end

  vim.ui.input({
    prompt = "Google:",
    default = selected_text .. ' ',
  }, query("https://www.google.com/search?q="))
end, opt)
-- end googling, }

-- capture
map('n', '<leader>vc', function()
  vim.ui.input({ prompt = 'Capture: ' }, function(input)
    if input and input ~= '' then
      local today_date = os.date('%Y-%m-%d %H:%M:%S')
      vim.fn.writefile({ "* [".. today_date .."] " .. input }, vim.fn.expand(vim.g.m_notes_path .. "/daily_reminder.md"), "a")
    end
  end)
end, { desc = 'Ask for text and append to end of file' })

map('n', '<leader>vb', function()
  local reg_p = vim.trim(vim.fn.getreg('*'))
  if reg_p == "" or not vim.startswith(reg_p, "http") then
    vim.notify("Register @* isn't an url:'"..reg_p.."'")
    return
  end
  vim.notify("Bookmarking:" .. reg_p)
  vim.ui.input({ prompt = string.sub(reg_p,1, 50) }, function(input)
    if input and input ~= '' and reg_p and reg_p ~='' then
      vim.fn.writefile({ "[" .. input .. "](" .. reg_p .. ")"  }, vim.fn.expand(vim.g.m_notes_path .. "/bookmarks.md"), "a")
    end
  end)
end, {silent = true, desc = 'Ask for text and append to end of file' })

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
  end, { desc = 'Ask for text and append to end of file' })

-- end capture

map("n", "<leader>c<space>", "gcc", {remap = true, silent=true, desc = "toggle comment"})
map("v", "<leader>c<space>", "gc", {remap = true, silent=true, desc = "toggle comment"})


map("v", "Y", function()
  vim.cmd.normal([["*y]])
  local reg = vim.fn.getreg('*')
  vim.notify("@*="..reg)
end, {desc = "yank virtual into system clipboard"})


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


map("n", "<leader>tk",
  function()
    local cmd_str =
[[
  KITTYCONF=~/.config/kitty/kitty.conf
  if grep -q '^hide_window_decorations yes' "$KITTYCONF"; then
    sed -i '/^hide_window_decorations yes/d' "$KITTYCONF"
  else
    echo 'hide_window_decorations yes' >> "$KITTYCONF"
  fi
]]

    vim.system({ "sh", "-c", cmd_str }, { text = true }, function(obj)
      if obj.code == 0 then
        vim.schedule(function()
          print("Kitty window decorations toggled successfully!\nIf fullscreen, may bork")
        end)
      else
        vim.schedule(function()
          print("Error toggled kitty decorations: " .. (obj.stderr or ""))
        end)
      end
    end)

  end,
  { desc = "Toggle Kitty Window Decorations" })
