local F = require("utils.functions")
local alt_key = F.format_os_altkey
local map = F.map
local ts = require("mini.trailspace")

local CAPTURE_NOTE_DIR = vim.fn.expand(vim.g.m_notes_path .. '/CAPTURE_NOTES')

vim.keymap.set(
  'n',
  "<leader>mk",
  function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, bufnr)

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, F.get_keys())
    vim.cmd("sort")
  end,
  {desc = "utils.keys"}
)

-- map('n', '<leader>vn', ":vnew<CR>", {})
map('n', alt_key('<%s-q>',3), ":qa!<CR>", {desc="force quit everything"})
-- map('n', alt_key('<%s-r>', 2), "<cmd>restart<CR>", {desc="restart nvim"}) --
-- restart does weird thing

map({ 'n', 'v' }, 'j', "gj", {silent=true, desc = "virtual line movement"})
map({ 'n', 'v' }, 'k', "gk", {silent=true, desc = "virtual line movement"})
-- map({ "n", "v" }, "0", "g0", {silent=true, desc = "virtual line movement"})
-- map({ "n", "v" }, "$", "g$", {silent=true, desc = "virtual line movement"})

-- horizonal split
map('n', '<C-x>',
  function()
    Snacks.bufdelete()
    vim.cmd.close()
  end,{desc = "close this buffer :clo"})

map({'n', 'x', 'v'}, 'q', '<nop>', { desc = 'Disable macro recording on q' })
-- map('n', alt_key("M", 3), 'q', { desc = 'Remap macro recoring to C-Q' })
map('n', '<C-q>', function() Snacks.bufdelete() end,{desc = "snakcs buf delete"})

map({'n', 'i', 'v'}, '<C-s>',
  function()
    vim.cmd("stopinsert")
    ts.trim()
    ts.trim_last_lines()
    vim.cmd("write")
  end,{silent = true, desc="save buffer"})
map('i', '<C-j>', "<Esc>o",{silent = true, desc="in middle of line, and still new line below"})
map('i', '<C-k>', "<Esc>O",{silent = true, desc="in middle of line, and still new line above"})
map({'i', 'n'}, "<C-p>", "<cmd>bprevious<cr>",{silent = true, desc="buffer previous"})
map({'i', 'n'}, "<C-n>", "<cmd>bnext<cr>",{silent = true, desc="buffer next"})

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

map({ "i", "v", "s", "n"}, "<C-c>", "<C-c><cmd>noh<CR>" , {noremap = true, desc="Esc and call no highlight"})

-- shortcut to google
local function query(query_url)
  return function(input)
    if input and input ~="" then
      local query = vim.uri_encode(input)
      vim.ui.open(query_url .. query)
    end
  end
end

-- map("n", "<leader>gy", function()
--   vim.ui.input( { icon=" ",prompt = "Youtube:"}, query("https://www.youtube.com/results?search_query="))
-- end, {desc="query youtube"})

local function google(prompt, default)
  vim.ui.input({
    icon = "󰊭 ",
    prompt = prompt,
    default = default .. ' ',
  }, query("https://www.google.com/search?q="))
end

-- map("n", "<leader>gr", function()  google(" Reddit", "reddit") end, {desc="query reddit"})
-- map("n", "<leader>gv", function()  google(" nvim", "nvim lua") end, {desc="query nvimn"})

map({"n","v" }, "<C-l>", function()
  local current_mode = vim.fn.mode(1)
  local selected_text = ""
  if current_mode == "v" or current_mode ==  "V" then
    vim.cmd('noautocmd normal! "vy') -- yank selected into register v
    selected_text = vim.fn.getreg('v'):gsub("\r?\n", "")
  end

  google(" oogle", selected_text)
end, {desc="googling google"})
-- end googling, }

-- end capture

map("n", "<leader>c<space>", "gcc", {remap = true, silent=true, desc = "toggle comment"})
map("v", "<leader>c<space>", "gc", {remap = true, silent=true, desc = "toggle comment"})

map("v", "Y", function()
  vim.cmd.normal([["+y]])
  vim.cmd.normal([["*y]])
  local reg = vim.fn.getreg('+')
  vim.notify("@+="..reg)
end, {desc = "yank virtual into system clipboard"})

-- map("n", "<leader>pp", '"*p', {desc="paste @* clipboard", remap=false})

vim.keymap.set('n', '<leader><leader>o', function()
  vim.ui.open(vim.fn.expand('%'))
end, { desc = 'Open current buffer with system handler' })

-- how to define this but ignore minifiles
map('n', "<C-d>", '<C-d>zz', { desc = "half page down, centered" })
map('n', "<C-u>", '<C-u>zz', { desc = "half page up, centered" })

map('n', "G", function() vim.cmd("normal! G") vim.cmd("normal! zz") end, { desc = "up, centered" })

map('n', "<leader>cl", function()
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
    local reg_value = vim.fn.getreg('+')
    local lines = vim.split(reg_value, '[\r\n]+', {})
    vim.api.nvim_put(lines, "c", false, true)
    vim.cmd("stopinsert")
    vim.cmd('normal `[V`]=')
  elseif code == 0 and vim.bo.filetype == "markdown" then
    vim.cmd("PasteImage")
  end
end, {
  desc="paste from @*. When markdown, check whether system clipboard is an image",
  silent = true,
  noremap =true
})

local function capture_note(lines, filetype)
  local leading = {'```'..filetype}
  local ending = {'```'}

  vim.ui.input({prompt = "Note header for filetype:" .. filetype}, function(input)
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
  local reg_p = vim.trim(vim.fn.getreg('+'))
  if vim.startswith(reg_p, "http") then
    vim.notify("Bookmarking http:" .. reg_p)
    vim.ui.input({ prompt = string.sub(reg_p,1, 50) }, function(input)
      local note_text = { string.format("[%s](%s)", input, reg_p) }
      local full_path = vim.fn.expand( vim.g.m_notes_path .. "/bookmarks.md")
      vim.fn.writefile(note_text, full_path ,"a")
    end)
  elseif reg_p ~= "" then
    vim.notify("Capturing note from @p:" .. reg_p)
    lines = vim.split(reg_p, '\n', {plain = true})
    vim.ui.input({ prompt = "Capture reg @+ as filetype"}, function(filetype)
      capture_note(lines, filetype)
    end)
  elseif reg_p == "" then
    vim.notify("empty register. nothing to capture.", vim.log.levels.WARN)
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

for i = 1, 9 do
  map("n", string.format("z%s", i), function() vim.wo.foldlevel = i - 1 end, {desc = "fold level "..i-1})
end

map("n", "<leader>ww",
  function()
    vim.cmd.edit(string.format("%s/%s",vim.g.m_notes_path, "index.md" ))
    vim.cmd("normal! Gzz")
  end,
  {desc = "My Notes" }
)

map("n", "<C-1>",
  function()
    local session_name = vim.fs.basename( vim.v.this_session )
    if session_name ~= "" then
      local filename = vim.fn.expand(vim.g.m_notes_path .. '/sessions/'..session_name .. ".md")
      vim.cmd.vsplit(filename)
    else
      vim.notify("Not in a session", vim.log.levels.WARN)
    end
  end, {desc = "session note"})

map("n", "<C-2>",
  function()
    local basename = vim.bo.filetype .. ".md"
    local filename = CAPTURE_NOTE_DIR .. "/" .. vim.bo.filetype .. ".md"
    vim.cmd.vsplit(filename)
  end, {desc = "session note"})

map("t", "<C-/>", "<cmd>stopinsert<CR>", {desc = "Escape to normal mode"})
map("n", "<C-/>", "<cmd>terminal<CR>", {desc = "Escape to normal mode"})

map('n', "<C-a>",
  function()
    local session_name = vim.fs.basename( vim.v.this_session )
    if session_name == "" then
      vim.notify("Not in a session", vim.log.levels.WARN)
      return
    end

    local filename = vim.fn.expand(vim.g.m_notes_path .. '/sessions/'..session_name .. ".md")

    local bufnr = vim.fn.bufnr(filename)
    if bufnr == -1 then
      vim.cmd.vsplit(filename)
    else
      local winid = vim.fn.bufwinid(bufnr)
      if winid ~= -1 then
        vim.api.nvim_set_current_win(winid)
      else
        vim.cmd(string.format("vertical sbuffer %s", bufnr))
      end
    end

    vim.ui.input(
      {prompt="Insert todo heading  " .. session_name},
      function(heading)
        local bufnr = vim.api.nvim_get_current_buf()
        -- Loop through each line of an external file

        local lines = vim.api.nvim_buf_get_lines(0, 3, -1, false)

        local insert_line = 3
        local todo_insert_newline = false
        for i, line in ipairs(lines) do
          if not vim.startswith(line, "- [") then
            insert_line = insert_line + i-1
            if vim.trim(line) ~= "" then
              todo_insert_newline = true
            end
            break
          end
        end

        heading = string.gsub(heading, "[^%w_]", " ")
        heading = vim.trim(heading):gsub("  ", " ")

        vim.api.nvim_buf_set_lines(0, -1, -1, false, {"", "# "..heading })

        local link = string.format("- [ ] [[%s]]", "#" .. heading:gsub(" ", "-"))
        vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, {link, todo_insert_newline and "" or nil})
      end
              )
  end, {desc = "add note to session"})
