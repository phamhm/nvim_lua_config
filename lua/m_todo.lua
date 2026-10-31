local F = require('utils.functions')

local TODO = {}

local TODO_FILE_PATH = vim.fn.expand(vim.g.m_notes_path .. "/TODO")
local TIME_PREFIXES = {"m_todo_Created", "m_todo_Started", "m_todo_Finished"}

vim.api.nvim_set_hl(0, "finished_hl", {
  fg = "grey",        -- Foreground color (Hex)
})

vim.api.nvim_set_hl(0, "pending_hl", {
  fg = "green",        -- Foreground color (Hex)
  bold = true,           -- Text style attribute
  italic = true,         -- Text style attribute
})

vim.api.nvim_set_hl(0, "started_hl", {
  fg = "yellow",        -- Foreground color (Hex)
  bold = true,           -- Text style attribute
  italic = true,         -- Text style attribute
})

local function get_times(path)
  return vim.iter(vim.fn.readfile(path))
    :filter(
      function(line)
        local time_type,_ = line:gsub(":.*", "")
        return vim.tbl_contains(TIME_PREFIXES, vim.trim(time_type))
      end)
    :fold({}, function(acc, val)
      local time_type, date_time = unpack(vim.split(val, ':'))
      acc[time_type] = date_time
      return acc
    end)
end

-- replace the first instance of old text with new text
-- if there are multiple instances of old text, only the first one get replaced
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
    title = title or "select to run",
    layout = {
      hidden = actions.hidden or {"input"},
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
    format = actions.m_format,
    finder = actions.m_finder,
    matcher = {sort_empty = true},
    sort = { fields = { "priority:desc", } },
  })
end

local function move_file(picker, sub_dir)
  if not sub_dir or sub_dir=="" then
    vim.notify("Subdir missing, can't rename", vim.log.levels.ERROR)
    return
  end

  F.clear_todo()
  local items = picker:selected({ fallback = true })

  --remove items from list before actually removing the files
  local indices_to_remove = vim.iter(items):map(function(i) return i.idx end):totable()
  picker.list.items = vim.iter(picker.list.items)
    :filter(
      function(i)
        return not vim.tbl_contains(indices_to_remove, i.idx)
      end
    ):totable()

  picker.list:update({force = true})

  vim.iter(items)
    :each(
    function(item)
      local from = item._path

      local from_path = vim.fs.dirname(from)
      local filename = item.text

      local to = string.format("%s/%s/%s", from_path, sub_dir, filename):gsub("//", "/")

      Snacks.rename.rename_file({
        from = from,
        to = to
      })

    end)
  picker:refresh()
end

function TODO.todo()
  vim.cmd("fclose!")
  -- opening a headless buffer

  local todo_files = vim.fn.globpath(TODO_FILE_PATH, "*.md", 0, 1)
  -- 4. Open the Snacks picker if we found any links
  if #todo_files == 0 then
    vim.notify("No todo item", vim.log.levels.WARN)
    return
  end

  local m_actions = {
  }

  function m_actions.set_todo(picker, item)
    local items = picker:selected({ fallback = true })
    if #items>1 then
      vim.notify("Can't set todo from multiple items")
      return
    end

    local todo = item.text:gsub("-"," "):gsub(".md", "")
    F.set_todo(todo, item._path)
  end

  function m_actions.discard_notes(picker, _)
    move_file(picker, "DISCARDED")
  end

  function m_actions.done_notes(picker, _)
    move_file(picker, "DONE")
  end

  function m_actions.m_transform(item)
    return item
  end

  function m_actions.resort_by_score(picker)
    table.sort(picker.list.items, function(i1, i2) return i1.priority > i2.priority end)
    picker.list:update({force = true})
  end

  function m_actions.m_finder()
    -- return {file = , text, cwd, status_hl_group and score}
    local files =vim.fn.globpath(TODO_FILE_PATH, "*.md", 0, 1)
    return vim.iter(files)
      :map(function(file)
        local item = {}
        item.file = vim.fs.basename(file)
        item.cwd = vim.fs.dirname(file)

        local times = get_times(file)
        local started = times.m_todo_Started
        local finished = times.m_todo_Finished

        local status = ""
        if finished and finished ~= "" then
          status= " "
          item.status_hl_group = "finished_hl"
          item.priority = 0
        elseif started and started ~="" then
          status= " "
          item.status_hl_group = "started_hl"
          item.priority = 999
        else
          status = " "
          item.status_hl_group = "pending_hl"
          item.priority =100
        end

        item.text = status .. " " ..item.file:gsub("-"," "):gsub(".md","")
        item.started = vim.trim(started)

        return item
      end)
      :fold({}, function(acc, item)
        table.insert(acc, item)
        return acc
      end)
  end

  function m_actions.m_format(item, _)
    return { { item.text , item.status_hl_group }, }
  end

  function m_actions.m_advance_todo(picker, item)
    local items = picker:selected({ fallback = true })
    if #items>1 then
      vim.notify("Can't advance time on multiple items", vim.log.levels.ERROR)
      return
    end

    local file_path = item.cwd .. '/' .. item.file
    local times = get_times( file_path )
    local started = times.m_todo_Started
    local finished = times.m_todo_Finished
    local new_date = os.date("%Y-%m-%d %H%M")
    local todo = item.text:gsub("-"," "):gsub(".md", "")
    if started and started == "" then
      replace_first_in_buffer(file_path, "m_todo_Started:", "m_todo_Started: " .. new_date)
      m_actions.set_todo(picker, item)
    elseif finished and finished == "" then
      replace_first_in_buffer(file_path, "m_todo_Finished:", "m_todo_Finished: " .. new_date)
      if todo == F.get_todo() then
        F.clear_todo()
      end
    end

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
    ["<C-m>"] = { "done_notes", mode = {"i", "n"}},
    ["<C-x>"] = { "discard_notes", mode = {"i", "n"}},
    ["<C-t>"] = { "set_todo", mode = {"i", "n"}},
    ["<C-r>"] = { "resort_by_score", mode = {"i", "n"}},
  }
  local actions, keys = F.gen_picker_actions(nil, m_actions, m_keys)
  todo_picker("Select TODO item(s)", actions, keys)
end

F.map("n", "<C-`>", TODO.todo, {desc = "calling todo"})

F.map("n", F.format_os_altkey("<C-%s-`>"),
  function()
    local file_path
    if F.get_todo_path() ~= "" then
      file_path = F.get_todo_path()
    else
      file_path = vim.fn.expand(vim.g.m_notes_path .. "/index.md")
    end
    Snacks.scratch({
      file = file_path,
      name = file_path,
    })
  end
  , {desc = "Scratch doing or reminders"})
