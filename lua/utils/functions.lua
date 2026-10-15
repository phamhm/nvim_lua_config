local M = {}

function M.copy_dated_lines(filepath, pattern)
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

function M.commands_menu(items, title)
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

function M.open_markdown_links_picker()
  -- 1. Define the path to your file
  local file_path = vim.fn.expand(vim.g.m_vimwiki_path .. "/bookmarks.md") -- Change this to your file path

  -- 2. Read lines from the file
  local lines = vim.fn.readfile(file_path)
  local items = {}

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
        elseif  vim.endswith(item.link, ".zsh") then
          cmd = {"zsh", vim.fn.expand( item.link )}
        elseif item.link == "edit" then
          vim.cmd.edit(file_path)
          return
        else
          vim.notify("Unexpected format " .. item.text .. ":" .. item.link, vim.log.levels.ERROR)
          return
        end
        if type(cmd) == "table" and next(cmd) ~= nil then
          vim.system(cmd, { detach = true}, function(err, _)
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

return M
