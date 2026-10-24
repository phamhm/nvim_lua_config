local M = require('markdowns')
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

--[[
-- take m_text and append to the end of target_path
--
--]]
function F.append_text_to_file(m_text, target_path)
  m_text = vim.trim(m_text)
  if m_text=="" then
    vim.notify("Text is blank. Can't append to file")
    return
  end
  local expanded_path = vim.fn.expand(target_path)

  local file, err = io.open(expanded_path, "a")
  if not file then
    vim.notify("Failed to open file: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  file:write("\n" .. m_text)
  file:close()
end

function F.move_lines_select_file()
  local winid = vim.api.nvim_get_current_win()

  local v_pos = vim.fn.getpos "v"
  local d_pos = vim.fn.getpos "."

  if v_pos[2] > d_pos[2] then
    local tmp = d_pos
    d_pos = v_pos
    v_pos = tmp
  end


  local _, start_row,_, _ = unpack(v_pos)
  local _, end_row, _, _ = unpack(d_pos)

  local bufnr = vim.api.nvim_get_current_buf()

  local m_lines
  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == "\22" then
    m_lines = vim.fn.getregion(v_pos, d_pos, {type=mode})
  else
    m_lines = {vim.trim(vim.api.nvim_get_current_line())}
  end

  for i, val in ipairs(m_lines) do
    -- ^- matches a literal hyphen at the very beginning of the string
    m_lines[i] = string.gsub(val, "^%-", "\n#")
  end

  m_lines = table.concat(m_lines, "\n")

  Snacks.picker.files({
    cwd = "~/Documents/notes/",
    actions = {
      confirm = function(picker, item)
        if item then
          picker:close()
          F.append_text_to_file(m_lines, item._path)

          vim.api.nvim_set_current_win(winid)
          vim.api.nvim_buf_set_lines(bufnr, start_row-1, end_row, false, {})
        end
      end
    }
  })
end

function F.move_line_to_file(target_path, l_formatter)
  -- local choice = vim.fn.confirm("Proceed to refile to ".. target_path.."?", "&Yes\n&No", 2)
  -- if choice ~= 1 then
  --   return
  -- end

  l_formatter = l_formatter or function(x) return x end

  -- 1. Expand the target path (handles ~ or relative paths safely)
  local expanded_path = vim.fn.expand(target_path)

  -- 2. Get the current cursor line text
  local current_line = vim.api.nvim_get_current_line()
  current_line = l_formatter(current_line)
  if current_line == "" then
    vim.notify("Can't move line")
    return
  end

  local file, err = io.open(expanded_path, "a")
  if not file then
    vim.notify("Failed to open file: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  file:write(current_line.. "\n")
  file:close()

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
    vim.notify("No Markdown link found on this line.", vim.log.levels.WARN)
    return
  end

  -- Strip the outer brackets and parentheses to get clean strings
  local link_text = vim.trim(string.sub(bracket_match, 2, -2))
  local url = vim.trim(string.sub(paren_match, 2, -2))

  local file, err = io.open(expanded_path, "a")
  if not file then
    vim.notify("Failed to open file: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  file:write(string.format("[%s](%s)", link_text, url).. "\n")
  file:close()

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

function F.copy_dated_lines(filepath, pattern)
  -- Expand the file path (handles ~ for home directory, etc.)
  local expanded_path = vim.fn.expand(filepath)

  -- Open the file in read mode
  local file = io.open(expanded_path, "r")
  if not file then
    vim.notify("Could not open file: " .. expanded_path, vim.log.levels.ERROR)
    return
  end

  local matched_lines = {}
  -- Lua pattern matching line start '^', literal bracket '%[',
  -- 4 digits '%d%d%d%d', dash '%-', 2 digits, dash, 2 digits, literal bracket '%]'
  -- Read file line by line
  for line in file:lines() do
    if vim.startswith(line, pattern) then
      table.insert(matched_lines, line)
    end
  end
  file:close()

  -- Check if any lines matched
  if #matched_lines == 0 then
    vim.notify("No matching lines found starting with [yyyy-mm-dd]", vim.log.levels.WARN)
    return
  end

  -- Join lines with newlines and set the '*' register (system clipboard)
  local content = table.concat(matched_lines, "\n")
  vim.fn.setreg('*', content)

  vim.notify(string.format("Copied %d lines to the * register!", #matched_lines), vim.log.levels.INFO)
end

local m_layout = {
  preview = false,
  layout = {
    width = 0.3,
    height = 0.5,
  }
}

function F.menu_commands(items, title)
  Snacks.picker.pick({
    pattern="^",
    items = items,
    title = title,
    format = "text",
    layout = m_layout,
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
local function open_md_link(md_link_item)
  -- item must contain item.link and item.text
  if not (md_link_item and md_link_item.link and md_link_item.text) then
    vim.notify("Item elements are missing")
    return
  end

  local cmd
  if type(md_link_item.link) == "function" then
    md_link_item.link()
  elseif vim.startswith(md_link_item.link, "http") or vim.endswith(md_link_item.link, ".rdp") then
    vim.ui.open(md_link_item.link) -- Open the link using your system's default handler
    return
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
    return
  else
    vim.notify("Unexpected format " .. md_link_item.text .. ":" .. md_link_item.link, vim.log.levels.ERROR)
    return
  end
  if type(cmd) == "table" and next(cmd) ~= nil then
    vim.system(cmd, { detach = true}, function(err)
      if err and err.code ~= 0 then
        vim.schedule(function()
          vim.notify("Failed to run:" .. vim.inspect(err), vim.log.levels.ERROR)
        end)
      end
    end)
  end
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

function F.generate_todo_picker()
  vim.cmd("fclose")
  local items = F.process_md_link_file(vim.g.m_notes_path .. "/todo.md")
  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
    vim.notify("No todo item", vim.log.levels.WARN)
    return
  end

  local fn_items_handler = function(bookmarks)
    for _, bookmark in ipairs(bookmarks) do
      open_md_link(bookmark)
    end
  end

  local actions, keys = F.gen_default_picker_actions(fn_items_handler)
  F.m_picker(items, "Select TODO item(s)", actions, keys)
end

-- generate a keys and actions to handle multiple items.
-- if you pass in anything that need access to the list, user must provide that object with the m_actions.
-- otherwise, m_actions methods won't be able to access the same picker_items list from this scope
function F.gen_default_picker_actions(fn_items_handler, m_actions, m_keys)
  if m_actions and not m_actions.picker_items then
    vim.notify("Passing in m_actions withou an picker_items", vim.log.levels.ERROR)
    return
  end

  local keys ={
    ["<C-d>"]     = { "rm_item_from_list", mode = { "i", "n" } },
    ["<C-l>"]     = { "clear_list", mode        = { "i", "n" } },
    ["<C-space>"] = { "add_item_to_list", mode  = { "i", "n" } },
    ["<C-Enter>"] = { "open_list", mode         = { "i", "n" } },
  }

  local picker_items = m_actions and m_actions.picker_items or {}

  local actions = {
    picker_items = picker_items,
    open_list = function(picker, item)
      picker:close()
      fn_items_handler(picker_items)
    end,

    fn_confirm = function(picker, item)
      picker:close()
      fn_items_handler({item})
    end,

    fn_preview = function(picker)
      local preview = {
        string.format("Action: %s", picker.item.link),
        "",
        "<C-d> remove <C-l> clear",
        "<C-space> add <C-Enter> execute"
      }
      if #picker_items>0 then
        table.insert(preview,"")
        for i, selected in ipairs(picker_items) do
          local item = string.format("%s %s : %s", i, selected.text, selected.link)
          table.insert(preview, item)
        end
      end

      update_picker_preview(picker.buf, preview)
    end,

    add_item_to_list = function(picker, item)
      --1. activate the preview if not
      --2. add item to a picker_items in scope.
      --3. refresh the preview buffer with the list
      if picker.preview.win.enabled == false then
        picker:toggle("preview")
      end
      local dup_found = false
      for i, val in ipairs(picker_items) do
        if val.text == item.text and val.link == item.link then
          dup_found=true
        end
      end

      if not dup_found then
        table.insert(picker_items, item)
      end

      if picker and picker.preview then
        picker.preview:refresh(picker)
      end
    end,

    rm_item_from_list = function(picker, item)
      --1. activate the preview if not
      --2. remove item from picker_items in scope.
      --3. refresh the preview buffer with the list
      if picker.preview.win.enabled == false then
        picker:toggle("preview")
      end

      for i, val in ipairs(picker_items) do
        if val.idx == item.idx then
          table.remove(picker_items, i)
        end
      end

      if picker and picker.preview then
        picker.preview:refresh(picker)
      end
    end,

    clear_list = function(picker, item)
      --1. activate the preview if not
      --2. remove item from picker_items in scope.
      --3. refresh the preview buffer with the list
      if picker.preview.win.enabled == false then
        picker:toggle("preview")
      end

      picker_items = {}

      if picker and picker.preview then
        picker.preview:refresh(picker)
      end
    end,

  }
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

  local fn_items_handler = function(bookmarks)
    for _, bookmark in ipairs(bookmarks) do
      open_md_link(bookmark)
    end
  end

  local actions, keys = F.gen_default_picker_actions(fn_items_handler)

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
    layout = m_layout,
    actions = actions,
    win = {
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
