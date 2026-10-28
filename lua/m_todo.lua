local F = require('utils.functions')

local TODO = {}

local TODO_FILE_PATH = vim.fn.expand(vim.g.m_notes_path .. "/TODO")

-- take items that has the item.content, and flatten it
local function flatten_picker_items(items)
  return vim.iter(items)
    :map(function(item) return item.content end)
    :flatten():totable()
end

local function get_times(path)
  local time_prefixes = {"m_todo_Created:", "m_todo_Started:", "m_todo_Finished:"}

  local lines = vim.iter(vim.fn.readfile(path))
    :filter(
      function(line)
        for _, prefix in ipairs(time_prefixes) do
          if vim.startswith(line, prefix) then
            return true
          end
        end
      end)
    :flatten()
    :fold({}, function(acc, val)
      local res = vim.split(val, ':')
      acc[res[1]] = res[2]
      return acc
    end)
  return lines
end

local function update_time(file_path)
  local dir_iter = vim.fs.dir(TODO_FILE_PATH)
  return vim.iter(dir_iter)
    :filter(function(name, ft) return ft=="file" end)
    :map(function(name)
      local path = TODO_FILE_PATH..'/'..name
      return { [path] = get_times(path) }
    end)
    :fold({}, function(acc, obj)
    return vim.tbl_deep_extend("force", acc, obj)
  end)
end

local function load_file_in_background(filepath)
  -- 1. Create a new, valid buffer (listed=true, scratchpad=false)
  local bufnr = vim.api.nvim_create_buf(true, false)

  -- 2. Set the file path/name for the newly created buffer
  vim.api.nvim_buf_set_name(bufnr, filepath)

  -- 3. Run the edit command strictly inside that buffer's context to populate it
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd.edit({ bang = true })
  end)

  -- Returns the buffer number so you can manipulate or display it later
  return bufnr
end


local function replace_first_in_buffer(filepath, old_text, new_text)
  -- Expand system paths like ~/ or $HOME
  local expanded_path = vim.fn.expand(filepath)

  if vim.fn.filereadable(expanded_path) == 0 then
    vim.notify("Error: File not found: " .. expanded_path, vim.log.levels.ERROR)
    return
  end

  -- 1. Create a hidden background buffer and load the file lines into it
  local bufnr = vim.fn.bufadd(expanded_path)
  vim.fn.bufload(bufnr)

  -- 2. Fetch all lines from the background buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local target = string.format("^%s$", old_text)
  local replaced = false

  -- 3. Loop through lines to find and swap the first match
  for i, line in ipairs(lines) do
    if line:match(target) then
      -- Replace just that specific line (0-indexed API)
      vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { new_text })
      replaced = true
      break -- Exit instantly so subsequent matches aren't touched
    end
  end

  -- 4. If a change happened, commit it silently to disk and clean up
  if replaced then
    -- Write the hidden buffer changes to disk
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("silent update")
    end)
    vim.notify("Replaced first match in background buffer for: " .. filepath, vim.log.levels.INFO)
  else
    vim.notify("Pattern not found in: " .. filepath, vim.log.levels.WARN)
  end

  -- 5. Delete the hidden buffer from memory to keep things clean
  -- vim.api.nvim_buf_delete(bufnr, { force = true })
end

local function todo_picker(title, actions, keys)
  if not actions then
    vim.notify("No actions for picker", vim.log.levels.ERROR)
    return
  end

  Snacks.picker.files({
    exclude = {"DONE/", "DISCARDED/", "templates/"},
    cwd = TODO_FILE_PATH,
    title = title or "select to run",
    format = "text", -- Display only the title in the list
    layout = {
      hidden = actions.hidden or {"preview"},
      layout = {
        width = actions.width or 0.9,
        height = actions.height or 0.9,
        box = "horizontal",
        {
          box = "vertical",
          { win = "input", height = 1, border = "rounded" },
          { win = "list", border = "rounded" },
        },
        {
          win = "preview",
          title = "{preview}",
          width = 0.8, -- 70% of the picker width goes to the preview window
          border = "rounded"
        },
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
      preview = {
        keys = { },
      },
    },
    -- preview = actions.fn_preview,
    confirm = actions.fn_confirm,
    transform = actions.m_transform,
  })
end

function TODO.todo()
  vim.cmd("fclose")
  -- opening a headless buffer

  local files = update_time(TODO_FILE_PATH)

  -- 4. Open the Snacks picker if we found any links
  -- if file_counter == 0 then
  --   vim.notify("No todo item", vim.log.levels.WARN)
  --   return
  -- end

  local m_actions = {
    hidden = {"input"},
  }

  function m_actions.set_todo(picker, item)
    local items = picker:selected({ fallback = true })
    if #items>1 then
      vim.notify("Can't set todo from multiple items")
      return
    end

    if F.get_todo() == item.raw_heading then
      F.clear_todo()
    else
      F.set_todo(item.raw_heading)
    end
  end

  function m_actions.discard_notes(picker, item)
    F.clear_todo()
    local items = picker:selected({ fallback = true })

    local it = vim.iter(items)
      :map(function(item)
        local f_path = item._path
        local p_path = vim.fs.dirname(f_path)
        local fname = item.text
        local new_path = p_path .. '/DISCARDED/' .. fname

        vim.uv.fs_rename(f_path, new_path, function() vim.notify("renamed to " .. new_path) picker:refresh() end)

        return ""
      end)
      :totable()
  end

  function m_actions.done_notes(picker, item)
    F.clear_todo()
    local items = picker:selected({ fallback = true })

    local it = vim.iter(items)
      :map(function(item)
        local f_path = item._path
        local p_path = vim.fs.dirname(f_path)
        local fname = item.text
        local new_path = p_path .. '/DONE/' .. fname

        vim.uv.fs_rename(f_path, new_path, function() vim.notify("renamed to " .. new_path) picker:refresh() end)

        return ""
      end)
      :totable()
  end

  function m_actions.m_transform(item, ctx)
    item.text = item.text:gsub("-", " "):gsub(".md", "")
    local path = item.cwd .. '/' .. item.file
    local times = files[path]
    local started = times.m_todo_Started
    local finished = times.m_todo_Finished

    if finished and finished ~= "" then
      item.text = " " .. item.text:gsub("-", " "):gsub(".md", "")
      item.status = 1
    elseif started and started ~="" then
      item.text = " " .. item.text:gsub("-", " "):gsub(".md", "")
      item.status = 2
    else
      item.status = 3
    end
    return item
  end

  function m_actions.m_advance_todo(picker, item)
    local items = picker:selected({ fallback = true })
    if #items>1 then
      vim.notify("Can't advance time on multiple items", vim.log.levels.ERROR)
      return
    end

    local file_path = item.cwd .. '/' .. item.file
    local times = files[file_path]
    local started = times.m_todo_Started
    local finished = times.m_todo_Finished
    local new_date = os.date("%Y-%m-%d %H%M")
    if started and started == "" then
      replace_first_in_buffer(file_path, "m_todo_Started:", "m_todo_Started: " .. new_date)
    elseif finished and finished == "" then
      replace_first_in_buffer(file_path, "m_todo_Finished:", "m_todo_Finished: " .. new_date)
    end

    files = update_time(TODO_FILE_PATH)
    picker:refresh()
  end


  function m_actions.fn_confirm(picker, item)
    picker:close()
    Snacks.scratch.open({file = item._path, name = item.text})
  end

  local m_keys = {
    ["<C-a>"] = { "m_advance_todo", mode = {"i", "n"}},
    ["<C-j>"] = { "list_down", mode = {"i", "n"}},
    ["<C-k>"] = { "list_up", mode = {"i", "n"}},
    ["<C-f>"] = { "done_notes", mode = {"i", "n"}},
    ["<C-x>"] = { "discard_notes", mode = {"i", "n"}},
    ["<C-w>l"] = { "focus_preview", mode = {"n"}},
  }
  local actions, keys = F.gen_picker_actions(nil, m_actions, m_keys)
  todo_picker("Select TODO item(s)", actions, keys)
end

F.map("n", "<C-`>", TODO.todo, {desc = "calling todo"})
