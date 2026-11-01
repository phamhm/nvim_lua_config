local F = require('utils.functions')

local TODO = {}

local TODO_FILE_PATH = vim.fn.expand(vim.g.m_notes_path .. "/TODO")
local TODO_PREFIX_YAML = {"m_todo_Title", "m_todo_Created", "m_todo_Started", "m_todo_Finished"}

local DONE        = "0"
local STARTED     = "9"
local PENDING     = "5"
local  STATUS_MAP = {
  [DONE] =    {icon = "  " , hl_group = "finished_hl"},
  [STARTED] = {icon = "  " , hl_group = "started_hl"},
  [PENDING] = {icon = "  " , hl_group = "pending_hl"},
}

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

local function get_yaml_config(path)
  return vim.iter(vim.fn.readfile(path))
    :filter(
      function(line)
        local time_type,_ = line:gsub(":.*", "")
        return vim.tbl_contains(TODO_PREFIX_YAML, vim.trim(time_type))
      end)
    :fold({}, function(acc, val)
      local key, value = unpack(vim.split(val, ':'))
      acc[key] = vim.trim(value):gsub("^'(.*)'$", "%1")
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
    cwd = TODO_FILE_PATH,
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
    sort = { fields = { "status:desc", } },
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
      local filename = item.file

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

    F.set_todo(item.text, item._path)
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

  function m_actions.m_finder(picker)
    -- return {file = , text, cwd, status_hl_group and score}
    local files =vim.fn.globpath(picker.cwd, "*.md", 0, 1)
    return vim.iter(files)
      :map(function(file)
        local item = {}
        item.file = vim.fs.basename(file)
        item.cwd = picker.cwd

        local yaml_config = get_yaml_config(file)
        item.text = yaml_config.m_todo_Title
        local started = yaml_config.m_todo_Started
        item.started = started and vim.trim(started)
        local finished = yaml_config.m_todo_Finished

        if finished and finished ~= "" then
          item.status= DONE
        elseif started and started ~="" then
          item.status= STARTED
        else
          item.status = PENDING
        end

        return item
      end)
      :fold({}, function(acc, item)
        table.insert(acc, item)
        return acc
      end)
  end

  function m_actions.m_format(item, _)
    local status = STATUS_MAP[item.status] or {icon = "??" , hl_group = "Comment"}
    return { { status.icon .. ' ' .. item.text , status.hl_group }, }
  end

  function m_actions.m_advance_todo(picker, item)
    local items = picker:selected({ fallback = true })
    if #items>1 then
      vim.notify("Can't advance time on multiple items", vim.log.levels.ERROR)
      return
    end

    local file_path = item.cwd .. '/' .. item.file
    local yaml_config = get_yaml_config( file_path )
    local started = yaml_config.m_todo_Started
    local finished = yaml_config.m_todo_Finished
    local new_date = os.date("%Y-%m-%d %H%M")
    local todo = item.text
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
  }
  local actions, keys = F.gen_picker_actions(nil, m_actions, m_keys)
  todo_picker("Select TODO item(s)", actions, keys)
end

F.map("n", "<C-`>", TODO.todo, {desc = "calling todo"})
