local M = require('utils.markdowns')

local F = {}

local custom_key_maps = {}

function F.save_keys(key)
  if not vim.tbl_contains(custom_key_maps, key) then
    table.insert(custom_key_maps, key)
  end
end

function F.map(mode, lhs, rhs, opt)
  local key = lhs ..":".. (opt.desc or "no description")
  F.save_keys(key)
  vim.keymap.set(mode, lhs, rhs, opt)
end

function F.get_keys()
  return MiniAlign.align_strings(custom_key_maps, {split_pattern=':'})
end

function F.write_note(note_text, destination)
  destination = destination or  vim.g.m_notes_path .. "/capture_notes.md"
  if note_text and note_text ~= "" then
    local today_date = os.date('%Y-%m-%d %H:%M')
    vim.fn.writefile({ "- ".. note_text .. " @c(".. today_date ..") " }, vim.fn.expand(destination), "a")
  end
end

-- this get the current line in the buffer
function F.move_line_to_file(target_path, l_formatter)
  l_formatter = l_formatter or function(x) return x end

  -- 1. Expand the target path (handles ~ or relative paths safely)
  local expanded_path = vim.fn.expand(target_path)

  -- 2. Get the current cursor line text
  local current_line = vim.api.nvim_get_current_line()
  current_line = l_formatter(current_line)
  if current_line == "" then
    vim.notify("Can't move empty line")
    return
  end

  local res = vim.fn.writefile(current_line, expanded_path, "a")
  if res == -1 then
    return
  end

  -- 5. Delete the line from the active Neovim buffer
  -- nvim_buf_set_lines replaces a range of lines. Passing an empty table {} deletes them.
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})

  vim.notify("Line appended to " .. target_path, vim.log.levels.INFO)
end

function F.bookmark_line(target_path)
  -- 1. Expand the target path (handles ~ or relative paths safely)
  local expanded_path = vim.fn.expand(target_path)

  -- 2. Get the current cursor line text
  local current_line_content = vim.api.nvim_get_current_line()
  local pattern = "(%b[])(%b())"

  local bracket_match, paren_match = string.match(current_line_content, pattern)

  if not (bracket_match and paren_match) then
    -- vim.notify("No Markdown link found on this line.", vim.log.levels.WARN)
    return
  end

  -- Strip the outer brackets and parentheses to get clean strings
  local link_text = vim.trim(string.sub(bracket_match, 2, -2))
  local url = vim.trim(string.sub(paren_match, 2, -2))

  local line = string.format("[%s](%s)", link_text, url)
  local res = vim.fn.writefile(line, expanded_path, "a")
  if res == -1 then
    return
  end

  -- 5. Delete the line from the active Neovim buffer
  -- nvim_buf_set_lines replaces a range of lines. Passing an empty table {} deletes them.
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})

  vim.notify("Line appended to " .. target_path, vim.log.levels.INFO)
end


function F.format_os_altkey(key_formatter, repeat_n)
  repeat_n = repeat_n or 1
  -- example <C-%s-j> will return <C-D-j> on osx and <C-M-j> on everything else
  local md_key = jit.os == "OSX" and "D" or "M"
  local key = string.format(key_formatter, md_key)

  return string.rep(key, repeat_n)
end

function F.menu_commands(items, title)
  Snacks.picker.pick({
    pattern="^",
    items = items,
    title = title,
    format = "text",
    layout = {
      preview = false,
      layout = {
        width = 0.3,
        height = 0.5,
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
    vim.notify("Item elements are missing")
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
      vim.fn.expand( md_link_item.link ),
    }
  elseif vim.fn.filereadable(vim.fn.expand(md_link_item.link)) == 1 then
    local file_path = vim.fn.expand(md_link_item.link)
    vim.cmd.edit(file_path)
    return true
  else
    vim.notify("Unexpected format " .. md_link_item.text .. ":" .. md_link_item.link, vim.log.levels.ERROR)
    return nil
  end
  if type(cmd) == "table" and next(cmd) ~= nil then
    vim.system(cmd, { detach = true}, function(err)
      if err and err.code ~= 0 then
        vim.schedule(function()
          vim.notify("Failed to run:" .. vim.inspect(err), vim.log.levels.ERROR)
        end)
      end
    end)
    return true
  end
  return nil
end

local function update_picker_preview(buf, preview)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, preview)
end

function F.process_md_link_file(filepath)
  local items = {} -- must be first line

  -- 1. Define the path to your file
  local bookmark_file_path = vim.fn.expand(filepath) -- Change this to your file path
  -- 2. Read lines from the file
  local lines = vim.fn.readfile(bookmark_file_path)

  -- 3. Parse each line for the [title](link) format
  for _, line in ipairs(lines) do
    local title, link = line:match("%[(.-)%]%((.-)%)")
    if title and link then
      table.insert(items, {
        text = vim.trim(title),    -- What shows up and is searchable in the picker
        link = vim.trim(link),     -- Store the URL to use on confirmation
        raw  = line
      })
    end
  end
  return items
end

-- pass nil to new_line and that line will be removed
local function replace_line_in_file(filepath, old_line, new_line)
  -- 1. Open the file in read mode
  --
  filepath = vim.fn.expand(filepath)
  local file = io.open(filepath, "r")
  if not file then
    error("Could not open file for reading: " .. filepath)
  end

  -- 2. Read all lines into a table
  local lines = {}
  for line in file:lines() do
    if line == old_line then
      if new_line ~= nil then
        table.insert(lines, new_line)
      end
    else
      table.insert(lines, line)
    end
  end
  file:close()

  -- 3. Open the file in write mode to overwrite it with the modified content
  file = io.open(filepath, "w")
  if not file then
    error("Could not open file for writing: " .. filepath)
  end

  -- 4. Write the lines back to the file
  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:close()

  return true
end

function F.set_todo(todo)
  vim.g.m_todo = todo
end

function F.get_todo()
  return vim.g.m_todo
end

function F.clear_todo()
  vim.notify("Clear todo:" .. vim.g.m_todo)
  vim.g.m_todo = ""
end

function F.set_status(msg)
  vim.g.global_status = msg
end

function F.clear_status()
  vim.g.global_status = ""
end

-- "/archive/discarded_ideas.md"
local function _move_todo(from_file_path, current_line, to_file_path)
  local res = vim.fn.writefile(current_line, vim.fn.expand(vim.g.m_notes_path .. to_file_path), "a")
  if res ~= -1 then
    replace_line_in_file(from_file_path, current_line, nil)
  end
end

function F.generate_todo_picker()
  vim.cmd("fclose")
  local todo_file_path = vim.g.m_notes_path .. "/TODO.md"
  local items = F.process_md_link_file(todo_file_path)

  for _, item in ipairs(items) do
    local raw = item.raw
    local _, s_time, f_time = M.get_times(raw)
    if f_time then
      item.text = " "..item.text
    elseif s_time then
      item.text = " "..item.text
    end
  end

  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
    vim.notify("No todo item", vim.log.levels.WARN)
    return
  end

  local m_actions = {
    hidden = {"input"},
    archive_done = function(picker, item)
      local items = picker:selected({ fallback = true })
      if #items>1 then
        vim.notify("Can't archive multiple items")
        return
      end

      local current_line = item.raw
      local f_time = M.get_timestamp(current_line, "f")
      if f_time == nil then
        vim.notify("Cant archive unfinished task. Use Discard")
        return
      end
      -- delete the current line in the todo.md, and append it to done_tasks.md
      _move_todo(todo_file_path, current_line, "/archive/done_tasks.md")
      -- update the picker items. list
      picker.list.items = vim.tbl_filter(function(i) return i.raw~=item.raw end, picker.list.items)
      picker.list:update({ force = true })
    end,
    set_todo = function(picker, item)
      local items = picker:selected({ fallback = true })
      if #items>1 then
        vim.notify("Can't set todo from multiple items")
        return
      end
      if F.get_todo() == item.text then
        F.clear_todo()
      else
        F.set_todo(item.text)
      end
    end,
    advance_time = function(picker, item)
      local items = picker:selected({ fallback = true })
      if #items>1 then
        vim.notify("Can't advance time on multiple items")
        return
      end
      local current_line = item.raw
      local new_line = M.advance_todo_time(current_line)
      local _, s_time, f_time = M.get_times(new_line)

      if f_time then
        replace_line_in_file(todo_file_path, current_line, new_line)
        vim.notify("Completed task:" .. item.text)
        if current_line == F.get_todo then
          F.clear_todo()
        end

        local items = F.process_md_link_file(todo_file_path)
        for _, item in ipairs(items) do
          local raw = item.raw
          local _, s_time, f_time = M.get_times(raw)
          if f_time then
            item.text = " "..item.text
          elseif s_time then
            item.text = " "..item.text
          end
        end

        picker.list.items = items
        picker.list:update({ force = true })
      elseif s_time then
        F.set_todo(item.text)
        replace_line_in_file(todo_file_path, current_line, new_line)
        local items = F.process_md_link_file(todo_file_path)
        for _, item in ipairs(items) do
          local raw = item.raw
          local _, s_time, f_time = M.get_times(raw)
          if f_time then
            item.text = " "..item.text
          elseif s_time then
            item.text = " "..item.text
          end
        end

        picker.list.items = items
        picker.list:update({ force = true })
      end
    end,

    discard_task = function(picker, item)
      local items = picker:selected({ fallback = true })

      local choices
      if #items>1 then
        choices = { 'Multiple', 'Selected', 'Cancel' }
      elseif #items == 1 then
        choices = { 'Selected', 'Cancel' }
      else
        return
      end

      local _discard = function(item)
        vim.notify("Discarded:" .. item.text)
        _move_todo(todo_file_path, item.raw, "/archive/discarded_ideas.md")
        picker.list.items = vim.tbl_filter(function(i) return i.raw~=item.raw end, picker.list.items)
        picker.items = vim.tbl_filter(function(i) return i.raw~=item.raw end, picker.list.items)
      end

      vim.ui.select(choices, {
        prompt = 'Discard Multiples or Selected Item',
      }, function(choice)
          if choice == 'Multiple' then
            for i, m_item in ipairs(items) do
              _discard(m_item)
            end
          elseif choice == 'Selected' then
            _discard(item)
          else
            vim.notify("Discard Cancelled!")
            return
          end
          picker.list:update({ force = true })
        end)
    end,
    fn_preview = function(picker)
      local c_time, s_time, f_time = M.get_times(picker.item.raw)
      local preview = {
        string.format("TODO: %s", picker.item.text),
        string.format("@c:%s", c_time),
        string.format("@s:%s", s_time),
        string.format("@f:%s", f_time),
      }

      table.insert(preview,"")
      table.insert(preview,"Content of current todo:")
      local lines = vim.fn.readfile(vim.fn.expand(picker.item.link))
      vim.list_extend(preview, lines)

      update_picker_preview(picker.buf, preview)
    end,
  }

  local m_keys = {
    ["<C-a>"] = { "advance_time", mode = {"i", "n"}},
    ["<C-t>"] = { "set_todo", mode = {"i", "n"}},
    ["<C-s>"] = { "archive_done", mode = {"i", "n"}},
    ["<C-x>"] = { "discard_task", mode = {"i", "n"}},
  }

  local actions, keys = F.gen_picker_actions(nil, m_actions, m_keys)
  F.m_picker(items, "Select TODO item(s)", actions, keys)
end

-- generate a keys and actions to handle multiple items.
-- if you pass in anything that need access to the list, user must provide that object with the m_actions.
-- otherwise, m_actions methods won't be able to access the same picker_items list from this scope
function F.gen_picker_actions(fn_items_handler, m_actions, m_keys)
  local fn_items_handler = fn_items_handler or function(bookmarks)
    for _, bookmark in ipairs(bookmarks) do
      F.open_md_link(bookmark)
    end
  end

  -- keep this empty for now.
  -- not deleting in case I want to have a default keys in the future
  local keys ={}

  local actions = {
    fn_confirm = function(picker, item)
      picker:close()
      local items = picker:selected({ fallback = true })
      fn_items_handler(items)
    end,

    fn_preview = function(picker)
      local preview = {
        string.format("Action: %s", picker.item.link),
        "",
      }

      update_picker_preview(picker.buf, preview)
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
  vim.cmd("fclose")
  local items = F.process_md_link_file(vim.g.m_notes_path .. "/bookmarks.md")

  vim.list_extend(items, picker_list_files(vim.g.m_scripts))

  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
    vim.notify("No valid Markdown links found in the file", vim.log.levels.WARN)
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
    vim.notify("No actions for picker", vim.log.levels.ERROR)
    return
  end

  if not items or #items==0 then
    vim.notify("No item to pick")
    return
  end

  Snacks.picker.pick({
    source = "markdown_links",
    items = items,
    title = title or "select to run",
    format = "text", -- Display only the title in the list
    layout = {
      hidden = actions.hidden or {"preview"},
      layout = {
        width = actions.width or 0.3,
        height = actions.height or 0.5,
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

-- not using it. stash it here
-- map('n', '<leader>lu', function() prompt_and_run_lua("Lua command", "lua") end, { desc = 'Prompt and execute Lua code' })
local function prompt_and_run_lua(prompt, cmp_type)
  vim.ui.input({ prompt = prompt, completion = cmp_type }, function(input)
    -- If the user hits Esc or Cancels, input is nil
    if not input or input == "" then return end

    -- Compile the string into an executable Lua chunk
    local chunk, err = load(input)

    if chunk then
      -- Safely execute the compiled chunk
      local success, result = pcall(chunk)
      if not success then
        vim.notify("Runtime Error: " .. tostring(result), vim.log.levels.ERROR)
      end
    else
      vim.notify("Syntax Error: " .. tostring(err), vim.log.levels.ERROR)
    end
  end)
end

function F.set_title()
  local fname = vim.fn.expand('%:t')
  if not (fname and fname~="") then
    return "[no file]"
  end
  local icon = MiniIcons.get('file', fname).. ' '

  fname = vim.fn.expand('%:p:h:t')..'/' .. fname

  local session = vim.trim(vim.v.this_session)
  if session~="" then
    session = vim.fs.basename(vim.v.this_session).."::"
  else
    session = ""
  end

  local readonly = vim.bo[0].readonly and " " or " "
  local modified = vim.bo[0].modified and " " or icon

  return string.format("%s%s%s %s", session, fname, readonly, modified )
end

return F
