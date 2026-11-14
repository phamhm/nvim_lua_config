local F = require("utils.functions")
local map = F.map
local ts = require("mini.trailspace")

local CAPTURE_NOTE_DIR = vim.fn.expand(vim.g.m_notes_path .. '/CAPTURE_NOTES')

map(
  'n',
  "<leader>mk",
  function()
    Snacks.picker.keymaps({
      layout = {hidden = {"preview"}},
      transform = function(item)
        local desc = item.item.desc or ""
        return vim.startswith(desc, "[hp]")
      end,
    })
  end,
  {desc = "show my custom keys"}
)

-- map('n', '<leader>vn', ":vnew<CR>", {})
map('n', F.alt_key('<%s-q>',3), ":qa!<CR>", {desc="force quit everything"})
-- map('n', alt_key('<%s-r>', 2), "<cmd>restart<CR>", {desc="restart nvim"}) --
-- restart does weird thing

map({ 'n', 'v' }, 'j', "gj", {silent=true, desc = "virtual line movement"})
map({ 'n', 'v' }, 'k', "gk", {silent=true, desc = "virtual line movement"})
-- map({ "n", "v" }, "0", "g0", {silent=true, desc = "virtual line movement"})
-- map({ "n", "v" }, "$", "g$", {silent=true, desc = "virtual line movement"})


map("n", "<leader>vn", "<cmd>vnew<cr>", {desc = "new vertical"})

map('n', '<C-q>',
  function()
    -- only delete buffer if there is no other windows with the same buffer
    local bufnr = vim.api.nvim_get_current_buf()
    if #vim.fn.win_findbuf(bufnr) == 1 then
      Snacks.bufdelete()
    end

    -- only close windows if there are more than 1 non-floating windows.
    local normal_wins = vim.tbl_filter(function(win)
      return vim.api.nvim_win_get_config(win).relative == ""
    end, vim.api.nvim_tabpage_list_wins(0))
    if #normal_wins > 1 then
      vim.cmd.close()
    end
  end,{desc = "delete buffer and close windows"})

map( "n", "<leader>q", 'Q', { desc = 'nvim -1.13 multiple cursors' })

map({'n', 'i', 'v'}, '<C-s>', "<Esc><cmd>write<cr>" ,{silent = true, desc="save buffer"})

map('n', F.alt_key('<C-%s-f>'),
  function()
    F.NOTIFY("Clean up buffer")
    ts.trim()
    ts.trim_last_lines()
    if vim.bo.filetype == "markdown"  then
      vim.cmd([[g/^\s*[\*-]\s*$/d]])
    end
  end,{silent = true, desc="format buffer"})
map({'i', 'n'}, '<C-j>', function() vim.cmd("normal o") end,{silent = true, desc="in middle of line, and still new line below"})
map({'i', 'n'}, '<C-k>', function() vim.cmd("normal O") end,{silent = true, desc="in middle of line, and still new line below"})
-- map({'i', 'n'}, "<C-S-Tab>", "<cmd>bprevious<cr>",{silent = true, desc="buffer previous"})
-- map({'i', 'n'}, "<C-Tab>", "<cmd>bnext<cr>",{silent = true, desc="buffer next"})

-- balancing out the universe
map('i', '<C-l>', '<Del>', { noremap = true, silent = true, desc="delete next letter"})

-- Bringing the whole line up or down
-- Normal mode
map('n', F.alt_key("<C-%s-j>"), ':m .+1<CR>==', { silent = true, desc="move the whole block down" })
map('i', F.alt_key("<C-%s-j>"), '<Esc>:m .+1<CR>==gi', { silent = true, desc="move the whole block down" })
map('v', F.alt_key("<C-%s-j>"), ":m '>+1<CR>gv=gv", { silent = true, desc="move the whole block down" })
map('n', F.alt_key("<C-%s-k>"), ':m .-2<CR>==', { silent = true, desc="move the whole block up" })
map('i', F.alt_key("<C-%s-k>"), '<Esc>:m .-2<CR>==gi', { silent = true, desc="move the whole block up" })
map('v', F.alt_key("<C-%s-k>"), ":m '<-2<CR>gv=gv", { silent = true, desc="move the whole block up" })

-- simplify the capture. Don't need to move around.
-- keeps these here as example of moving with vim command
-- map("v", "<leader>td", ":'<,'>m ?^# Capture$?-2 <CR>")
-- map("n", "<leader>td", ":m ?^# Capture$?-2 <CR>")
-- map("v", "<leader>tc", ":'<,'>m /^# Capture$/ <CR>")
-- map("n", "<leader>tc", ":m /^# Capture$/ <CR>")

map({ "i", "v", "s", "n"}, "<C-c>",
  function()
    vim.cmd("fclose!")
    F.m_feedkey("<Esc>")
    vim.cmd('nohlsearch')

    local mc_ns = vim.api.nvim_create_namespace('nvim.multicursor')
    vim.api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
  end, {noremap = true, desc="Esc and call no highlight"})

-- shortcut to query
local function query(query_url)
  return function(input)
    if input and input ~="" then
      local query = vim.uri_encode(input)
      vim.ui.open(query_url .. query)
      local LOG_FILE = string.format("%s/logs/google_%s.md",vim.g.m_notes_path, os.date("%Y-%m-%d"))
      local log = string.format("[%s] %s", os.date("%H:%M"), input)
      vim.fn.writefile({ vim.trim(log) }, vim.fn.expand(LOG_FILE), "a")
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

  google("Google", selected_text)
end, {desc="googling google"})
-- end googling, }

-- end capture

map("n", "<leader>c<space>", "gcc", {remap = true, silent=true, desc = "toggle comment"})
map("v", "<leader>c<space>", "gc", {remap = true, silent=true, desc = "toggle comment"})

map({"v", "n"}, "<C-y>", function()
  if vim.fn.mode() == "n" then
    vim.fn.setreg("+", vim.fn.getreg('"'))
    F.NOTIFY('Copied @" into @+ :'.. vim.fn.getreg('"'))
  else
    vim.cmd.normal([["+y]])
    vim.cmd.normal([["*y]])
    local reg = vim.fn.getreg('+')
    F.NOTIFY("Yank into @+ :"..reg)
  end
end, {desc = "yank virtual into system clipboard"})

-- map("n", "<leader>pp", '"*p', {desc="paste @* clipboard", remap=false})

map('n', F.alt_key("<%s-o>",3), function()
  local file = vim.fn.expand('%')
  if vim.endswith(file, ".html") then
    vim.ui.open(file)
  else
    F.WARN("Only open html file:" .. file)
  end
end, { desc = 'Open current buffer with system handler' })

-- how to define this but ignore minifiles
map('n', "<C-d>", '<C-d>zz', { desc = "half page down, centered" })
map('n', "<C-u>", '<C-u>zz', { desc = "half page up, centered" })

map('n', "G", function() vim.cmd("normal! G") vim.cmd("normal! zz") end, { desc = "up, centered" })

-- map('n', "<leader>cl", function()
--   F.clear_todo()
--   F.clear_status()
-- end, {desc = " clear global vim.g"})

map('i', "<C-p>", function()
  -- if markdown, call the scripts/get_clipboard.type.zsh
  --     the zsh has different code dependent on OS.
  -- if not an image, paste from clipboard @+
  --    after pasting from clipboard, select the pasted block and apply "="
  --    to autoindent
  -- if an image, call "img_clip"
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
    F.NOTIFY("Bookmarking http:" .. reg_p)
    vim.ui.input({ prompt = string.sub(reg_p,1, 50) }, function(input)
      local note_text = { string.format("[%s](%s)", input, reg_p) }
      local full_path = vim.fn.expand( vim.g.m_notes_path .. "/bookmarks.md")
      vim.fn.writefile(note_text, full_path ,"a")
    end)
  elseif reg_p ~= "" then
    F.NOTIFY("Capturing note from @p:" .. reg_p)
    lines = vim.split(reg_p, '\n', {plain = true})
    vim.ui.input({ prompt = "Capture reg @+ as filetype"}, function(filetype)
      capture_note(lines, filetype)
    end)
  elseif reg_p == "" then
    F.WARN("empty register. nothing to capture.")
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

map("n", "<leader>ss", 
  function() 
    local session_path = string.format("%s/sessions/",vim.g.m_notes_path)
    local session_commands = {
      {text = "select", fn = MiniSessions.select},
      {text = "save current", fn = MiniSessions.write},
      {text = "delete", fn = function() MiniSessions.select('delete', {force = true}) end},
      {text = "rename", fn = function()
        local sessions = require("mini.sessions")
        -- 1. select a session to rename
        -- 2. rename its session file.
        -- 3. rename its notes file
        vim.ui.select(vim.tbl_keys(sessions.detected), {prompt = "Select session to rename"},
          function(old_session_name)
            local current_session = vim.fs.basename(vim.v.this_session)
            if current_session == old_session_name then
              F.WARN("Can't rename current session")
              return
            end

            vim.ui.input({prompt = "New Session Name"},
              function(new_session_name)

                if not new_session_name or new_session_name == "" then
                  return
                end

                new_session_name = new_session_name:gsub(" ","_")

                local old_session_path = string.format("%s/%s", MiniSessions.config.directory, old_session_name):gsub("//", "/")
                local new_session_path = string.format("%s/%s", MiniSessions.config.directory, new_session_name):gsub("//", "/")
                if vim.uv.fs_stat(old_session_path) then
                  vim.fn.rename(old_session_path, new_session_path)
                else
                  F.NOTIFY("Session not found:" .. old_session_path)
                  return
                end

                local old_session_note_path = string.format("%s/%s.md", session_path, old_session_name):gsub("//", "/")
                local new_session_note_path = string.format("%s/%s.md", session_path, new_session_name):gsub("//", "/")
                if vim.uv.fs_stat(old_session_note_path) then
                  vim.fn.rename(old_session_note_path, new_session_note_path)
                end

              end)
          end
        )
      end},
      {text = "rebuild", fn = function()
        local sessions = require("mini.sessions")
        vim.ui.select(vim.tbl_keys(sessions.detected), {prompt = "Select session to rebuild"},
          function(session_name)
            if session_name and session_name ~= "" then
              require('snacks').bufdelete.all()
              MiniSessions.write(session_name)
              local session_note_path = string.format("%s/%s.md", session_path, session_name)
              vim.cmd.edit(session_note_path)
              if not vim.uv.fs_stat(session_note_path) then
                return
              end

              local data, err = get_yaml(session_note_path)
              if data then
                if data.session_path and data.session_path ~= "" then
                  vim.cmd.edit(data.session_path)
                end
                if data.other_paths and #data.other_paths > 0 then
                  vim.iter(data.other_paths):each(function(path) vim.cmd.badd(path) end)
                end
              else
                F.ERROR("Yaml parse error")
              end
            end
          end)
      end},
      {text = "new session", fn = function()
        vim.ui.input({ prompt = 'Session Name: ' }, function(new_session_name)
          if new_session_name and new_session_name ~= '' then
            require('snacks').bufdelete.all()
            MiniSessions.write(new_session_name)
            local session_note = string.format("%s/%s.md", session_path, new_session_name)
            local yaml = {
              "---",
              "session_path:",
              "---"
            }
            vim.fn.writefile(yaml, session_note)
            vim.cmd.edit(session_note)
          end
        end)
      end} ,
    }
    F.menu_commands(session_commands, "Session commands", "")
  end, {desc = "session management"})

map("n", '<leader>sn',
  function()
    local session_path, session_name, session_note = F.get_session_paths()
    if session_name and vim.uv.fs_stat(session_note) then
      F.snacks_grep_markdown(session_note)
    elseif not session_name or session_name == "" then
      F.ERROR("Not in a session")
    else
      F.ERROR("SessionNote NOT found:" .. session_note)
      vim.cmd.edit(session_path)
    end
  end,
  {desc="open session_path"}
)
map("n", "<leader>1",
  function()
    local session_path, session_name, session_note = F.get_session_paths()
    local current_file = vim.fn.expand("%:p")

    -- close window if in it. Toggle behavior
    if current_file == session_note and #vim.api.nvim_list_wins() > 1 then
      vim.cmd.close()
      return
    end

    if session_name and vim.uv.fs_stat(session_note) then
      F.open_markdown_file(session_note, nil, true)
    elseif not session_name or session_name == "" then
      F.ERROR("Not in a session")
    else
      F.ERROR("SessionNote NOT found:" .. session_note)
      vim.cmd.edit(session_path)
    end
  end, {desc = "session note"})

map("n", "<leader>2",
  function()
    local basename = vim.bo.filetype .. ".md"
    local filename = CAPTURE_NOTE_DIR .. "/" .. vim.bo.filetype .. ".md"
    vim.cmd.vsplit(filename)
  end, {desc = "file type note"})

map("n", "<C-/>", function()
  local terminal_bufs = vim.tbl_filter(function(bufnr)
    return vim.bo[bufnr].buftype == 'terminal'
  end, vim.api.nvim_list_bufs())

  if #terminal_bufs > 1 then
    F.WARN(string.format("Too many terminal buffers: %s", #terminal_bufs))
    return
  elseif #terminal_bufs == 1 then
    local bufnr = terminal_bufs[1]
    vim.cmd("belowright split")
    vim.api.nvim_win_set_buf(0, bufnr)
  else
    vim.cmd("belowright split | terminal")
  end
  vim.cmd("startinsert")

  -- Print the buffer numbers
end , {desc = "open terminal"})
map("t", "<C-/>", function() vim.cmd("stopinsert") end, {desc = "Escape terminal to normal mode"})

map('n', "<C-a>",
  function()
    local session_path, session_name, session_note = F.get_session_paths()
    if session_name and vim.uv.fs_stat(session_note) then
      F.open_markdown_file(session_note, nil, true)

      vim.ui.input(
        {prompt="Insert todo heading  " .. session_name},
        function(heading)
          if heading and heading ~= "" then
            vim.api.nvim_buf_set_lines(0, -1, -1, false, {"", "# "..heading })
            vim.cmd.write()
          else
            vim.cmd.close()
          end
        end)
    elseif not session_name or session_name == "" then
      F.ERROR("Not in a session")
      return
    else
      F.ERROR("SessionNote NOT found:" .. session_note)
      vim.cmd.edit(session_path)
      return
    end
  end, {desc = "add note to session"})

-- Map =ai to format without losing your cursor position
map('n', F.alt_key("<%s-f>") , function()
  -- 1. Save the current window and cursor position
  -- 2. Format the text block using mini.ai
  F.m_feedkey('=ai', 'ntm')

  -- 3. Wait for the keystrokes to finish, then snap the cursor back
  vim.schedule(function()
    -- Ensure the window still exists before setting the cursor
    if vim.api.nvim_win_is_valid(current_win) then
      vim.api.nvim_win_set_cursor(current_win, cursor_pos)
    end
  end)
end, { desc = "Format around inner block (keeps cursor position)" })


map({"n", "i"}, "<C-t>", "<cmd>t.<cr>", {desc="ex t copy line reserve cursor column"})

vim.keymap.set('n', 'm', function()
  -- Wait for user to type the mark character
  local ok, char = pcall(vim.fn.getcharstr)
  if ok and char and char:match('%a') then
    vim.cmd('normal! m' .. char)
    F.NOTIFY(string.format('Mark set: %s', char))
  end
end, { desc = 'Set mark with notification' })

map("v", ".", function() vim.treesitter.select("parent") end, {desc = "treesitter select parent"})
map("v", F.alt_key("<%s-.>"), function() vim.treesitter.select("child") end, {desc = "treesitter select child"})
map("v", F.alt_key("<%s-n>"), function() vim.treesitter.select("next") end, {desc = "treesitter select next"})
map("v", F.alt_key("<%s-p>"), function() vim.treesitter.select("prev") end, {desc = "treesitter select prev"})

map({"v", "n"}, "<leader>xe",
  function()
    if vim.fn.mode() == "n" then
      vim.cmd("%lua")
      return
    end

    local start_pos = vim.fn.getpos('v')
    local end_pos = vim.fn.getpos('.')
    local lines = vim.fn.getregion(start_pos, end_pos, { type = vim.fn.mode() })

    local selected_text = table.concat(lines, "\n")
    local fn, err = loadstring(selected_text)
    if fn then
      fn()
    else
      F.ERROR("Lua error: " .. err)
    end

  end, {desc = "execute highlited text as lua code"})
