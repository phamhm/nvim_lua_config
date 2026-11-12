local F = {}

local m_todo =  ""
local m_todo_path = ""
local m_status = ""

F.NOTIFY = function(msg) print(vim.inspect(msg)) end
F.ERROR  = function(msg) error(vim.inspect(msg)) end
F.WARN   = function(msg) vim.api.nvim_echo({ { msg, "WarningMsg" } }, true, {}) end
F.INFO   = function(msg) vim.notify(vim.inspect(msg), vim.log.levels.INFO) end
F.DEBUG  = function(msg) vim.notify(vim.inspect(msg), vim.log.levels.DEBUG) end
F.TRACE  = function(msg) vim.notify(vim.inspect(msg), vim.log.levels.TRACE) end

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
function F.format_os_altkey(key_formatter, repeat_n)
  repeat_n = repeat_n or 1
  -- example <C-%s-j> will return <C-D-j> on osx and <C-M-j> on everything else
  local md_key = jit.os == "OSX" and "D" or "M"
  local key = string.format(key_formatter, md_key)

  return string.rep(key, repeat_n)
end

function F.menu_commands(items, title, pattern, m_actions, m_keys)
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
      preview = false,
      layout = {
        min_width = 0,
        width = 0.6,
        height = 0.6,
      }
    },
    confirm = function(picker, item)
      picker:close()
      if item and item.fn then
        item.fn()
      end
    end,
    matcher = {
      fuzzy = false, -- use fuzzy matching
      smartcase = true, -- use smartcase
      ignorecase = true, -- use ignorecase
      sort_empty = false, -- sort results when the search string is empty
      filename_bonus = true, -- give bonus for matching file names (last part of the path)
      file_pos = true, -- support patterns like `file:line:col` and `file:line`
      -- the bonusses below, possibly require string concatenation and path normalization,
      -- so this can have a performance impact for large lists and increase memory usage
      cwd_bonus = false, -- give bonus for matching files in the cwd
      frecency = false, -- frecency bonus
    },
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
          text = "script:" .. vim.trim(name),    -- What shows up and is searchable in the picker
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

  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
    F.WARN("No valid Markdown links found in the file")
    return
  end

  local actions, keys = F.gen_picker_actions()

  F.m_picker(items, "Select Bookmark(s) to open",actions, keys)
end

-- my custom Snacks.picker.pick for multiple selections
-- User can do multiple selection, and executes all at once
-- default fn_item_handler is the open_item function
function F.m_picker(items, title, actions, keys)
  if not actions then
    F.ERROR("No actions for picker")
    return
  end

  if not items or #items==0 then
    F.NOTIFY("No item to pick")
    return
  end

  Snacks.picker.pick({
    source = "markdown_links",
    items = items,
    focus = "input",
    title = title or "select to run",
    format = "text", -- Display only the title in the list
    layout = {
      hidden = actions.hidden or {"preview", "input"},
      layout = {
        min_width = 0,
        width = 0.3,
        height =  0.5,
      }
    },
    actions = actions,
    win = {
      list = {
        keys = keys,
      },
      input = {
        keys = keys,
      },
    },
    preview = actions.fn_preview,
    confirm = actions.fn_confirm,
  })
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

  local Path = require("plenary.path")
  filename = vim.fn.fnamemodify(filename, ":~")
  filename = Path:new(filename):shorten(3)

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
      return path
    end)
    :totable()

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
  local note_width = 60
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
  local session_path = string.format("%s/sessions/",vim.g.m_notes_path)
  local session_name = vim.fs.basename(vim.v.this_session)
  local session_note = string.format("%s/%s.md", session_path, session_name):gsub("//", "/")
  return session_path, session_name, session_note
end

function F.get_markdown_lines(path)
  local yaml_mark_counter = 0
  local yaml_lines = {}
  local headers = {}
  local lnum = 0

  -- if path is already read into buffer, read from teh buffer
  -- wil read from non-visible buffer as well.
  local m_bufnr = -1
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == path then
      m_bufnr = bufnr
      break
    end
  end
  local lines
  if m_bufnr ~= -1 and vim.api.nvim_buf_is_loaded(m_bufnr) then
    F.NOTIFY("Processing lines from buffer")
    lines = vim.api.nvim_buf_get_lines(m_bufnr, 0, -1, false)
  else
    F.NOTIFY("Processing lines from file")
    lines = io.lines(path)
  end

  -- using vim.iter because io.lines is an iterator
  vim.iter(lines):each(
    function(line)
      lnum = lnum + 1
      if yaml_mark_counter ~= 2 then
        if line == "---" and lnum == 1 then
          yaml_mark_counter = 1
        elseif line == "---" and yaml_mark_counter == 1 then
          yaml_mark_counter = 2
        elseif yaml_mark_counter == 1 then
          table.insert(yaml_lines, line)
        end
      end

      -- appending headers and task items
      if vim.startswith(line, "#") or vim.startswith(vim.trim(line), "- [") then
        headers[string.format("%s (%s)", line, lnum)] = lnum
      end
    end)

  local yaml = require('yaml')
  local yaml_string = table.concat(yaml_lines, "\n")
  local locators, err = yaml.parse(yaml_string)
  locators.headers = headers
  return locators, err
end

function F.markdown_locators(path, pinned, ignore_yaml)
  ignore_yaml = ignore_yaml or false
  local data, err = F.get_markdown_lines(path)

  if data then
    local headers = data.headers
    data.headers = nil

    local sel_opts = vim.iter(vim.tbl_keys(data))
      :fold({},
      function(acc, key)
        local item = data[key]
        if vim.islist(item) then
          vim.list_extend(acc, item)
        else
          table.insert(acc, item)
        end
        return acc
      end)

    local sorted_header_keys =vim.tbl_keys(headers)
    table.sort(sorted_header_keys, function(a, b) return headers[a] < headers[b] end)

    if ignore_yaml then
      sel_opts = sorted_header_keys
    else
      sel_opts = vim.list_extend(sel_opts, sorted_header_keys)
    end

    sel_opts = vim.iter(sel_opts)
      :fold({},
      function(acc, locator)
        local item
        if vim.startswith(locator, "#") or vim.startswith(vim.trim(locator), "- [") then
          item = {
            text = locator,
            _path = path,
            fn = function() F.open_markdown_file(path, headers[locator], pinned) end
          }
        else
          local Path = require("plenary.path")
          locator, count = locator:gsub("/$","") -- remove here, else plenary will shorten the last one
          item = {
            text = Path:new(locator):shorten(1) .. (count>0 and "/" or ""),
            _path = vim.fn.expand(locator),
            fn = function()
              vim.cmd.edit(vim.fn.expand(locator))
            end
          }
        end
        table.insert(acc, item)
        return acc
      end
    )

    local m_actions = {
    }
    local m_keys = {
    }
    F.menu_commands(sel_opts, vim.fs.basename(path).. " Locators", "",  m_actions, m_keys)
  else
    F.ERROR("Yaml parse error")
  end
end

return F
