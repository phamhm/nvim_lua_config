local F = {}

function F.write_note(note_text)
  if note_text and note_text ~= "" then
    local today_date = os.date('%Y-%m-%d %H:%M:%S')
    vim.fn.writefile({ "- ".. note_text .. " [".. today_date .."] " }, vim.fn.expand(vim.g.m_notes_path .. "/working_notes.md"), "a")
  end
end

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


  local _, start_row,start_col, _ = unpack(v_pos)
  local _, end_row, end_col, _ = unpack(d_pos)

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

function F.move_line_to_file(target_path)
  -- 1. Expand the target path (handles ~ or relative paths safely)
  local expanded_path = vim.fn.expand(target_path)

  -- 2. Get the current cursor line text
  local current_line_content = vim.trim(vim.api.nvim_get_current_line())
  if current_line_content == "" then
    vim.notify("Can't move empty line")
    return
  end

  if current_line_content:match("^%-") then
    current_line_content = vim.trim(current_line_content:sub(2))
  end

  if not vim.startswith(current_line_content, "##") then
    current_line_content = "\n## "..current_line_content
  end

  local file, err = io.open(expanded_path, "a")
  if not file then
    vim.notify("Failed to open file: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  file:write(current_line_content.. "\n")
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

function F.open_markdown_links_picker()
  vim.cmd("fclose")
  local items = {} -- must be first line

  -- 1. Define the path to your file
  local bookmark_file_path = vim.fn.expand(vim.g.m_notes_path .. "/bookmarks.md") -- Change this to your file path
  -- 2. Read lines from the file
  local lines = vim.fn.readfile(bookmark_file_path)

  -- 3. Parse each line for the [title](link) format
  for _, line in ipairs(lines) do
    local title, link = line:match("%[(.-)%]%((.-)%)")
    if title and link then
      table.insert(items, {
        text = vim.trim(title),    -- What shows up and is searchable in the picker
        link = vim.trim(link),     -- Store the URL to use on confirmation
      })
    end
  end

  vim.list_extend(items, picker_list_files(vim.g.m_scripts))

  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
    vim.notify("No valid Markdown links found in the file", vim.log.levels.WARN)
    return
  end

  Snacks.picker.pick({
    source = "markdown_links",
    items = items,
    title = "Select Link to Open",
    format = "text", -- Display only the title in the list
    layout = m_layout,
    confirm = function(picker, item)
      picker:close()
      if item and item.link then
        local cmd
        if vim.startswith(item.link, "http") or vim.endswith(item.link, ".rdp") then
          vim.ui.open(item.link) -- Open the link using your system's default handler
          return
        elseif  vim.endswith(item.link, ".applescript") then
          cmd = {"osascript", vim.fn.expand( item.link )}
        elseif  vim.endswith(item.text, ".zsh") then
          cmd = {
            'kitten',
            '@',
            '--to',
            os.getenv("KITTY_LISTEN_ON"),
            'launch',
            '--type=tab',
            'zsh',
            '-f',
            vim.fn.expand( item.link ),
          }
        elseif item.link == "edit" then
          vim.cmd.edit(bookmark_file_path)
          return
        else
          vim.notify("Unexpected format " .. item.text .. ":" .. item.link, vim.log.levels.ERROR)
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
    end,
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


return F
