local F = require("utils.functions")
local alt_key = F.format_os_altkey
local map = F.map

local CAPTURE_NOTE_DIR = vim.fn.expand(vim.g.m_notes_path .. '/CAPTURE_NOTES')

vim.keymap.set(
  'n',
  "<leader>mk",
  function()
    local scratch = Snacks.scratch({
      ft = "text",
      name = "keys from utils.lua"
    })
    vim.api.nvim_buf_set_lines(0, 0, -1, false, F.get_keys())
    vim.cmd("sort")
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

map({'n', 'i', 'v'}, '<C-s>', "<Esc><cmd>w<cr>",{silent = true, desc="save buffer"})
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

map({ "i", "v", "n", "s" }, "<C-c>", "<C-c><cmd>noh<CR>" , {noremap = true, desc="Esc and call no highlight"})

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
  vim.ui.input( { icon=" ",prompt = "Youtube:"}, query("https://www.youtube.com/results?search_query="))
end, {desc="query youtube"})

local function google(prompt, default)
  vim.ui.input({
    icon = "󰊭 ",
    prompt = prompt,
    default = default .. ' ',
  }, query("https://www.google.com/search?q="))
end

map("n", "<leader>gr", function()  google(" Reddit", "reddit") end, {desc="query reddit"})
map("n", "<leader>gv", function()  google(" nvim", "nvim lua") end, {desc="query nvimn"})

map({"n","v" }, "<leader>gg", function()
  local current_mode = vim.fn.mode(1)
  local selected_text = ""
  if current_mode == "v" or current_mode ==  "V" then
    vim.cmd('noautocmd normal! "vy') -- yank selected into register v
    selected_text = vim.fn.getreg('v'):gsub("\r?\n", "")
  end

  google(" oogle", selected_text)
end, {desc="googling google"})
-- end googling, }

-- capture
map(
  'n',
  '<leader>cc',
  function()
    vim.ui.input({ prompt = 'Todo: ' },
      function(input)
        -- Obsidian new will open the new note.
        -- this will save my current buffer then switch back to it.
        local og_bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo.filetype
        vim.cmd("Obsidian workspace todo")
        local cmd = string.format("Obsidian new_from_template '%s' todo_notes", input:gsub('/',""))
        vim.cmd(cmd)
        local obsidian_buf = vim.api.nvim_get_current_buf()
        if og_bufnr and ft ~= "snacks_dashboard" then
          vim.api.nvim_set_current_buf(og_bufnr)
        end
        vim.api.nvim_buf_delete(obsidian_buf, {force = true})
      end)
  end,
  { desc = 'Capture text and apped to capture_notes.md' }
)

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

map("n", "<leader>pp", '"*p', {desc="paste @* clipboard", remap=false})

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

map('n', alt_key("<leader>cl"), function()
  F.clear_todo()
  F.clear_status()
end, {desc = " clear global vim.g"})

map('i', "<C-v>", function()
  -- if markdown, call the scripts/get_clipboard.type.zsh
  --     the zsh has different code dependent on OS.
  -- if not an image, paste from clipboard @+
  --    after pasting from clipboard, select the pasted block and apply "="
  --    to autoindent
  -- if an image, call "Obsidian paste_img"
  local code=1

  -- only check if it's markdown because running running a zsh script is slow.
  if vim.bo.filetype == "markdown" then
    local clip_board_zsh_path = vim.g.m_scripts .. '/get_clipboard_type.zsh'
    local result = vim.system({ "zsh", vim.fn.expand(clip_board_zsh_path) }, {
      text = true, -- Automatically decode stdout/stderr as strings
    }):wait()
   code = result.code
  end

  if code == 1 then
    -- paste from the @+ system clipboard register,
    -- select the pasted line(s) and autoindent
    vim.cmd('normal "+p`[V`]=')
  elseif vim.bo.filetype == "markdown" then
    vim.ui.input({prompt = "image name"}, function(input)
      vim.cmd("Obsidian paste_img "..input)
    end)
  end
end, {
  desc="paste from @*. When markdown, check whether system clipboard is an image",
  silent = true,
  noremap =true
})

map({'n', 'x', 'v'}, 'q', '<nop>', { desc = 'Disable macro recording on q' })
map('n', '<leader>Q', 'q', { desc = 'Remap macro recoring to C-Q' })

local function capture_note(lines, filetype)
  local leading = {'```'..filetype}
  local ending = {'```'}

  vim.ui.input({prompt = "Note header"}, function(input)
    local new_date = os.date("%Y-%m-%d %H:%M")
    local header = {"", string.format("# %s [%s]", input, new_date ), ""}
    local target_file = string.format("%s/%s.md", CAPTURE_NOTE_DIR, filetype)

    local yaml = {
      "---",
      "tags:",
      " - "..filetype,
      "---",
      ""
    }

    local lines_list = {header, leading, lines, ending}
    local stat = vim.uv.fs_stat(target_file)
    if stat == nil then
      lines_list = vim.list_extend(yaml, lines_list)
    end

    local note = vim.iter(lines_list):flatten():totable()
    vim.fn.writefile(note, target_file, "a")
  end)
end

local function capture_highlighted_block()
  local s_pos = vim.fn.getpos("v")
  local e_pos = vim.fn.getpos(".")

  -- Get the tert lines within that region
  local lines = vim.fn.getregion(s_pos, e_pos, { type = vim.fn.mode() })
  local filetype = vim.bo.filetype
  capture_note(lines, filetype)
end

local function capture_from_register()
  local reg_p = vim.trim(vim.fn.getreg('*'))
  if vim.startswith(reg_p, "http") then
    vim.notify("Bookmarking:" .. reg_p)
    vim.ui.input({ prompt = string.sub(reg_p,1, 50) }, function(input)
      local note_text = { string.format("[%s](%s)", input, reg_p) }
      local full_path = vim.fn.expand( vim.g.m_notes_path .. "/bookmarks.md")
      vim.fn.writefile(note_text, full_path ,"a")
    end)
  elseif reg_p ~= "" then
    vim.notify("Capturing note:" .. reg_p)
    lines = vim.split(reg_p, '\n', {plain = true})
    vim.ui.input({ prompt = "Capture notes file type" }, function(filetype)
      capture_note(lines, filetype)
    end)
  end
end

map({"v", "n"}, "<leader>bb",
  function()
    local mode = vim.fn.mode()
    if mode == "n" then
      capture_from_register()
    elseif  mode == 'v' or mode == 'V' or mode == '\22' then
      capture_highlighted_block()
    end
  end,
  {desc="make notes/bookmark from highlted text"})

map("n", "<leader>fn",
  function()
    local filetype = vim.bo.filetype
    local target_file = string.format("%s/%s.md", CAPTURE_NOTE_DIR, filetype)
    Snacks.scratch({
      file = target_file,
      name = target_file,
      enter = true
    })
  end, {desc = "open filetype note"})

map("n", "<C-w>f", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.focusable and config.relative ~= "" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  print("No floating window found")
end, { desc = "Jump to floating window" })
