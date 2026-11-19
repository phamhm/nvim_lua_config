local F = {}

local m_todo =  ""
local m_todo_path = ""
local m_status = ""

local function f_msg(msg)
  if vim.islist(msg) then
    return table.concat(msg, "\n")
  elseif type(msg) == "table" then
    return vim.inspect(msg)
  else
    return msg
  end
end
F.NOTIFY = function(msg) vim.notify(f_msg(msg)) end
F.ERROR  = function(msg) error(f_msg(msg)) end
F.WARN   = function(msg) vim.notify(f_msg(msg), vim.log.levels.WARN) end
F.INFO   = function(msg) vim.notify(f_msg(msg), vim.log.levels.INFO) end
F.DEBUG  = function(msg) vim.notify(f_msg(msg), vim.log.levels.DEBUG) end
F.TRACE  = function(msg) vim.notify(f_msg(msg), vim.log.levels.TRACE) end

function F.map(mode, lhs, rhs, opts)
  if opts == nil then
    opts = {silent = true, noremap = true, desc = "[no description]"}
  else
    if opts.silent == nil then
      opts.silent = true
    end
    if opts.noremap == nil then
      opts.noremap = true
    end
    if opts.desc == nil then
      opts.desc = "[no description]"
    end
  end

  opts.desc = "[hp]" .. opts.desc

  -- local key = lhs .."=".. (opts and opts.desc or "no description")
  -- F.save_keys(lhs, rhs, opts.desc, mode, "m_keys")
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- take note_text and write to destination with @c capture time

-- OSX and Linux call the alt key something different.
-- this will replace the %s with correct letter for different OSes.
function F.alt_key(key_formatter, repeat_n)
  repeat_n = repeat_n or 1
  -- example <C-%s-j> will return <C-D-j> on osx and <C-M-j> on everything else
  local md_key = jit.os == "OSX" and "D" or "M"
  local key = string.format(key_formatter, md_key)

  return string.rep(key, repeat_n)
end

function F.menu_commands(items, title, pattern, m_actions, m_keys, allow_multiples)
  allow_multiples = allow_multiples or false
  m_actions = m_actions or {}
  m_keys = m_keys or {}
  pattern = pattern or ""

  Snacks.picker.pick({
    pattern=pattern,
    items = items,
    title = title,
    format = "text",
    actions = m_actions,
    win = {
      input = { keys = m_keys },
      list = {keys = m_keys},
    },
    layout = {
      hidden = {"preview"},
      layout = {
        min_width = 0,
        width = 0.3,
        height = 0.5,
      }
    },
    confirm = function(picker, item)
      picker:close()
      local items = picker:selected({ fallback = true })
      if not allow_multiples and #items > 1 then
        F.ERROR("Multiple Selection not allowed")
        return
      end

      vim.iter(items):each(function(i) i.fn() end)
    end,
  })
end

local function picker_list_files(m_path)
  local items = {} -- must be first line

  local dir_path = vim.fn.expand(m_path)
  local handle = vim.uv.fs_scandir(dir_path)
  if handle then
    while true do
      local name, type = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end

      if type == 'file' and
        (vim.endswith(name, ".zsh") or
        vim.endswith(name, ".applescript") or
        vim.endswith(name, ".rdp")) then
        local full_path = dir_path ..  vim.trim(name)
        table.insert(items, {
          text = " " .. vim.trim(name),    -- What shows up and is searchable in the picker
          link = vim.trim(full_path),     -- Store the URL to use on confirmation
        })
      end
    end
  end
  return items
end

-- if item is an .com, then open it.
-- if applescript, call osascript to execute
-- .zsh, then open a new kitty tab to execute the code there
-- if text contains the word "edit" and the link is a readable file, then open it.
function F.open_md_link(md_link_item)
  -- item must contain item.link and item.text
  if not (md_link_item and md_link_item.link and md_link_item.text) then
    F.NOTIFY("Item elements are missing")
    return
  end

  local cmd
  if type(md_link_item.link) == "function" then
    md_link_item.link()
    return true
  elseif vim.startswith(md_link_item.link, "http") or
         vim.endswith(md_link_item.link, ".rdp") or
         vim.startswith(md_link_item.link,"msteams:/") or
         vim.startswith(md_link_item.link,"slack:/") then
    vim.ui.open(md_link_item.link) -- Open the link using your system's default handler
    return true
  elseif  vim.endswith(md_link_item.link, ".applescript") then
    cmd = {"osascript", vim.fn.expand( md_link_item.link )}
  elseif  vim.endswith(md_link_item.link, ".zsh") then
    cmd = {
      'kitten',
      '@',
      '--to',
      os.getenv("KITTY_LISTEN_ON"),
      'launch',
      '--type=tab',
      'zsh',
      '-f',
      string.format("%s/%s/%s", vim.fn.stdpath("config"), 'zsh_scripts', 'zsh_run_script.zsh'),
      vim.fn.expand( md_link_item.link ),
    }
  elseif vim.fn.filereadable(vim.fn.expand(md_link_item.link)) == 1 then
    local file_path = vim.fn.expand(md_link_item.link)
    vim.cmd.edit(file_path)
    return true
  else
    F.NOTIFY("Unexpected format " .. md_link_item.text .. ":" .. md_link_item.link, vim.log.levels.ERROR)
    return nil
  end
  if type(cmd) == "table" and next(cmd) ~= nil then
    vim.system(cmd, { detach = true}, function(err)
      if err and err.code ~= 0 then
        vim.schedule(function()
          F.ERROR("Failed to run:" .. vim.inspect(err))
        end)
      end
    end)
    return true
  end
  return nil
end

function F.update_picker_preview(buf, preview)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, preview)
end

function F.set_todo(todo, path)
  F.INFO("New Task:" .. todo)
  if not path or path == "" then
    F.WARN("Task with no file path")
  end
  m_todo = todo
  m_todo_path = path
end

function F.get_todo()
  local len = 20
  local todo = #m_todo<len and m_todo or vim.fn.strcharpart(m_todo, 0, len-3) .. "..."
  local icon = MiniIcons.get("file", "TODO")
  return string.format("[%s %s]", icon , todo)
end

function F.get_todo_path()
  return m_todo_path
end

function F.clear_todo()
  if m_todo ~="" then
    F.NOTIFY("Clear todo:" .. m_todo)
  end
  m_todo = ""
  m_todo_path = ""
end

function F.set_status(msg)
  m_status = msg
end

function F.get_status()
  return m_status
end

function F.clear_status()
  m_status = ""
end

-- generate a keys and actions to handle multiple items.
-- if you pass in anything that need access to the list, user must provide that object with the m_actions.
-- otherwise, m_actions methods won't be able to access the same picker_items list from this scope
function F.gen_picker_actions(fn_items_handler, m_actions, m_keys)
  fn_items_handler = fn_items_handler or function(bookmarks)
    for _, bookmark in ipairs(bookmarks) do
      F.open_md_link(bookmark)
    end
  end

  -- keep this empty for now.
  -- not deleting in case I want to have a default keys in the future
  local keys ={}

  local actions = {
    fn_confirm = function(picker, _)
      picker:close()
      local items = picker:selected({ fallback = true })
      fn_items_handler(items)
    end,

    fn_preview = function(picker)
      local preview = {
        string.format("Action: %s", picker.item.link),
        "",
      }

      F.update_picker_preview(picker.buf, preview)
    end,
  }

  -- if key collision like same function name, m_actions will override actions
  if m_actions then
    actions = vim.tbl_deep_extend("force", actions, m_actions)
  end
  if m_keys then
    keys = vim.tbl_deep_extend("force", keys, m_keys)
  end

  return actions, keys
end

-- this function will read from the notes/bookmarkds.md
-- AND the scripts in Documents/scripts
-- build a list of {text, link}
function F.generate_bookmarks_picker()
  vim.cmd("fclose!")

  local items = vim.iter(vim.fn.readfile(vim.fn.expand(vim.g.m_notes_path .. "/bookmarks.md")))
    :map(function(line)
      local title, link = line:match("%[(.-)%]%((.-)%)")
      return {text = vim.trim(title), link = vim.trim(link) }
    end)
    :fold({}, function(acc, item)
      table.insert(acc, item)
      return acc
    end)

  vim.list_extend(items, picker_list_files(vim.g.m_scripts))
  items = vim.iter(items)
    :map(
      function(item)
        return {text = item.text, fn = function() F.open_md_link(item) end}
      end)
    :totable()

  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
    F.WARN("No valid Markdown links found in the file")
    return
  end

  F.menu_commands(items, "Select Bookmark(s) to open", "", nil, nil, true)
end

function F.set_title()
  local session = vim.trim(vim.v.this_session)
  if session~="" then
    session = " "..vim.fs.basename(vim.v.this_session)
  else
    session = "[no session]"
  end
  local filename = vim.fn.expand('%:p')
  if not filename  or filename == "" then
    filename = "[no name]"
  end

  filename = vim.fn.fnamemodify(filename, ":~")
  filename = vim.fn.pathshorten(filename, 3)

  return string.format("%s::%s", session, filename)
end

function F.open_scratch(filename, name)
  vim.cmd("fclose!")
  Snacks.scratch({
    file = vim.fn.expand(filename),
    name = name,
    enter = true,
  })
end

function F.goto_md_link()
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request(0, "textDocument/definition", params,
    function( err, result, ctx, config )
      if result and result.uri then
        vim.lsp.util.show_document(result, "utf-8", {focus=true})
      else
        vim.cmd("normal gx")
      end
    end)
end

local function find_common_path(paths, sep)
  if #paths == 1 then
    return vim.fs.dirname(unpack(paths))
  end
  sep = sep or "/"
  if not paths or #paths == 0 then return "" end
  -- Helper function to split a string by separator
  local function split(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
      table.insert(t, str)
    end
    return t
  end
  local first_path_components = split(paths[1], sep)
  local max_common_len = #first_path_components
  for i = 2, #paths do
    local current_components = split(paths[i], sep)
    if #current_components < max_common_len then
      max_common_len = #current_components
    end
    for j = 1, max_common_len do
      if first_path_components[j] ~= current_components[j] then
        max_common_len = j - 1
        break
      end
    end
    if max_common_len == 0 then break end
  end
  local common_parts = {}
  for i = 1, max_common_len do
    table.insert(common_parts, first_path_components[i])
  end
  -- Preserve leading slash if the original paths were absolute
  local prefix = table.concat(common_parts, sep)
  if paths[1]:sub(1, 1) == sep then
    prefix = sep .. prefix
  end
  return prefix
end

function F.tar_files(tar_name, files)
  local tar_filename = string.format("~/Backups/%s.tar.gz",tar_name)
  local common_path = find_common_path(files)

  files = vim.iter(files)
    :map(function(file)
      local path, count = string.gsub(file, "^" .. common_path, ""):gsub("^/", "")
      return path ~= "" and path or nil
    end)
    :totable()

  -- take everything under the common path
  if #files == 0 then
    files = {"."}
  end

  tar_filename = vim.fn.expand(tar_filename)
  local cmd = {
    "tar",
    "-cvzf",
    tar_filename,
    "-C",
    common_path
  }
  vim.list_extend(cmd, files)

  vim.system(cmd, { cwd = path_to_files }, function(obj)
    if obj.code == 0 then
      print("Zipped successfully! Result:" .. tar_filename)
    else
      F.ERROR("Error zipping files: " .. obj.stderr)
    end
  end)
end

function F.m_feedkey(key, modes)
  modes = modes or "n"
  local term_code = vim.api.nvim_replace_termcodes(key, true, false, true)
  vim.api.nvim_feedkeys(term_code, modes, false)
end

function F.fn_feedkey(key, modes)
  return function()
    F.m_feedkey(key, modes)
  end
end

function F.open_markdown_file(path, lnum, pinned)
  if pinned == nil then
    pinned = true
  end
  local note_width = 70
  local buf_found = false
  if path ~= "" then
    path = vim.fn.expand(path)
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win_id)
      local bufname = vim.api.nvim_buf_get_name(buf)

      -- Check if bufname ends with or contains the target filename
      if bufname:match(vim.pesc(path) .. "$") or bufname:find(path, 1, true) then
        vim.api.nvim_set_current_win(win_id)
        buf_found = true
        break
      end
    end

    -- vim.cmd.vsplit(filename)
    -- if
    if not buf_found then
      vim.cmd(string.format("topleft %svsplit %s", note_width, path))
    end
    local win_id = vim.api.nvim_get_current_win()

    if lnum ~= nil then
      vim.api.nvim_win_set_cursor(win_id, {lnum, 0})
    else
      vim.cmd("normal! Gzt")
    end
    if pinned then
      vim.wo[win_id].winpinned = true
      vim.wo[win_id].winfixwidth = true
      vim.cmd(string.format("vertical resize %s", note_width))
    end
  else
    F.WARN("Path not found:" .. path)
  end
end

function F.get_session_paths()
  local session_dir = vim.fs.abspath(string.format("%s/sessions/",vim.g.m_notes_path))
  local session_name = vim.fs.basename(vim.v.this_session)
  local session_note_path = string.format("%s/%s.md", session_dir, session_name):gsub("//", "/")
  return session_dir, session_name, session_note_path
end

function F.snacks_grep_markdown(path, m_confirm)
  Snacks.picker.grep({
    m_source = "grep_markdown",
    search = "- ~|^#|- \\[-]|- \\[\\s]",
    dirs = {path},
    focus = "list",
    layout = {
      hidden = { 'preview'}
    },
    format = function(item, picker)
      local ret = {}
      -- if item.pos then
      --   ret[#ret + 1] = { string.format("[%3d] ", item.pos[1]), "SnacksPickerLineNr" }
      -- end
      ret[#ret + 1] = { item.line or "", "Normal" }
      return ret
    end,
    confirm = m_confirm or function(picker, item)
      picker:close()
      if item then
        local lnum, cnum = unpack(item.pos)
        F.open_markdown_file(path, lnum, true)
      end
    end
  })
end

function F.count_normal_windows()
  local count = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local config = vim.api.nvim_win_get_config(win)
    -- Floating windows have a non-empty 'relative' field; normal splits have ""
    if config.relative == "" then
      count = count + 1
    end
  end
  return count
end

function F.get_root_dir(current_cwd)
  current_cwd = current_cwd or vim.fn.expand("%:p")

  local markers = { '.git', "package.json", ".env" }

  return vim.fs.root( current_cwd, markers )
end

-- get visual lines and return a table of those lines.
-- if not visual mode, then return an empty table.
function F.get_visual_lines()
  -- Get the tert lines within that region
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' or mode == 'V' or mode == '\22' then
    return vim.fn.getregion(
      vim.fn.getpos("v"),
      vim.fn.getpos(".") ,
      { type = mode })
  else
    return {}
  end
end

function F.pick_win_action(action)
  return function()
    vim.cmd("fclose!")

    local fn = nil
    if type(action) == "function" then
      fn = action
    else
      fn = function()
        vim.cmd(action)
      end
    end

    local wins = vim.tbl_filter(function(win)
      return vim.api.nvim_win_get_config(win).focusable
    end, vim.api.nvim_tabpage_list_wins(0))
    -- Skip picking if there is only one window
    if #wins <= 1 then
      return
    end
    local floats = {}
    local win_map = {}
    -- 2. Create a centered floating badge for each window
    for i, win in ipairs(wins) do
      local label = tostring(i)
      win_map[label] = win
      -- Create a temporary scratch buffer for the number
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " .. label .. " " })
      -- Calculate the center of the target window
      local width = vim.api.nvim_win_get_width(win)
      local height = vim.api.nvim_win_get_height(win)
      local row = math.floor(height / 2) - 1
      local col = math.floor((width - 3) / 2)
      -- Open the floating window relative to the target window
      local float_win = vim.api.nvim_open_win(buf, false, {
        relative = "win",
        win = win,
        row = math.max(0, row),
        col = math.max(0, col),
        width = 3,
        height = 1,
        style = "minimal",
        border = "rounded",
        focusable = false,
        zindex = 250,
      })
      -- Apply high-visibility styling
      vim.api.nvim_set_option_value("winhl", "Normal:Search,FloatBorder:Search", { win = float_win })
      table.insert(floats, { win = float_win, buf = buf })
    end
    -- 3. Force a screen redraw so the floating numbers appear before blocking for input
    vim.cmd("redraw")
    -- 4. Wait for a single character input
    local ok, char = pcall(vim.fn.getcharstr)
    -- 5. Clean up all floating windows and buffers
    for _, item in ipairs(floats) do
      if vim.api.nvim_win_is_valid(item.win) then
        vim.api.nvim_win_close(item.win, true)
      end
      if vim.api.nvim_buf_is_valid(item.buf) then
        vim.api.nvim_buf_delete(item.buf, { force = true })
      end
    end
    -- 6. Jump to the selected window if the key matched
    if ok and win_map[char] and vim.api.nvim_win_is_valid(win_map[char]) then
      -- vim.api.nvim_set_current_win(win_map[char])
      vim.api.nvim_win_call(win_map[char], fn)
    end
  end
end

function F.save_bufs_then_act(action)
  local fn = action
  if type(action) ~= "function" then
    fn = function()
      vim.cmd(action)
    end
  end

  return function()
    F.NOTIFY("Saving All buffers")
    vim.iter(vim.api.nvim_list_bufs())
      :filter(function(bufnr)
        return vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified
      end)
      :each(function(bufnr)
      vim.api.nvim_buf_call(bufnr, function()
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name and name ~= "" then
          vim.cmd.update()
        else
          local f_name = vim.fn.tempname():gsub("/", "_")
          local tmp_name = string.format("/tmp/%s.txt", f_name)
          vim.cmd.write(tmp_name)
        end
      end)
    end)
    fn()
  end
end

function get_treesitter(bufnr, ft, query)
  local res = {}
  local parser = vim.treesitter.get_parser(bufnr, ft)
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = vim.treesitter.query.parse(ft, query)
  for _, node in query:iter_captures(root, bufnr, 0, -1) do
    local text = vim.treesitter.get_node_text(node, bufnr)
    table.insert(res, text)
  end
  return res
end

function F.get_md_frontformatter(bufnr)
  local yaml = require('yaml')

  local ft = "markdown"
  local query =  "(minus_metadata) @metadata"
  local res = get_treesitter(bufnr, ft, query)
  local m_yaml =  table.concat(res,"\n")

  local data, err = yaml.parse(m_yaml)
  if data then
    return data
  else
    print("Parse error:", err)
    return nil
  end
end

function F.get_md_headings(bufnr)
  local yaml = require('yaml')

  local ft = "markdown"
  local query = [[
  (atx_heading
    (atx_h1_marker)
    heading_content: (_) @h1_text)
  ]]
  return get_treesitter(bufnr, ft, query)
end

return F
