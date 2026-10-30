local F = require('utils.functions')

local TODO = {}

local TODO_FILE_PATH = vim.fn.expand(vim.g.m_notes_path .. "/TODO")

local function get_times(path)
  local time_prefixes = {"m_todo_Created", "m_todo_Started", "m_todo_Finished"}

  return vim.iter(vim.fn.readfile(path))
    :filter(
      function(line)
        local time_type,_ = line:gsub(":.*", "")
        return vim.tbl_contains(time_prefixes, vim.trim(time_type))
      end)
    :flatten()
    :fold({}, function(acc, val)
      local time_type, date_time = unpack(vim.split(val, ':'))
      acc[time_type] = date_time
      return acc
    end)
end

-- Each todo file has 3 times(capture, start and finish)
-- this function look at those time in the  yaml and create a list of them
-- then associates the file name with this list. Help with advancing time
local function map_file_to_times(file_path)
  local dir_iter = vim.fs.dir(file_path)
  return vim.iter(dir_iter)
    :filter(function(_, ft) return ft=="file" end)
    :map(function(name)
      local path = TODO_FILE_PATH..'/'..name
      return { [path] = get_times(path) }
    end)
    :fold({}, function(acc, obj)
    return vim.tbl_deep_extend("force", acc, obj)
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
    exclude = {"DONE/", "DISCARDED/", "templates/"},
    cwd = TODO_FILE_PATH,
    title = title or "select to run",
    layout = {
      hidden = actions.hidden or {"preview"},
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
    -- transform = actions.m_transform,
    format = actions.m_format,
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
  vim.cmd("fclose")
  -- opening a headless buffer

  local file_times_map = map_file_to_times(TODO_FILE_PATH)

  local file_counter = vim.tbl_count(file_times_map)

  -- 4. Open the Snacks picker if we found any links
  if file_counter == 0 then
    vim.notify("No todo item", vim.log.levels.WARN)
    return
  end

  local m_actions = {
    hidden = {"input"},
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

  function m_actions.m_format(item, _)
    local path = item.cwd .. '/' .. item.file
    local times = file_times_map[path]
    local started = times.m_todo_Started
    local finished = times.m_todo_Finished

    local status = ""
    if finished and finished ~= "" then
      status= " "
    elseif started and started ~="" then
      status= " "
    else
      status = " "
    end

    return {
      { status , "CursorLinNr" }, -- Replace with your desired highlight group
      { item.text:gsub("-", " "):gsub(".md", "") , "String" }, -- Replace with your desired highlight group
    }
  end

  -- function m_actions.m_transform(item, picker)
  -- end

  function m_actions.m_advance_todo(picker, item)
    local items = picker:selected({ fallback = true })
    if #items>1 then
      vim.notify("Can't advance time on multiple items", vim.log.levels.ERROR)
      return
    end

    local file_path = item.cwd .. '/' .. item.file
    local times = file_times_map[file_path]
    local started = times.m_todo_Started
    local finished = times.m_todo_Finished
    local new_date = os.date("%Y-%m-%d %H%M")
    local todo = item.text:gsub("-"," "):gsub(".md", "")
    if started and started == "" then
      replace_first_in_buffer(file_path, "m_todo_Started:", "m_todo_Started: " .. new_date)
      file_times_map[file_path]["m_todo_Started"] = new_date
      m_actions.set_todo(picker, item)
    elseif finished and finished == "" then
      replace_first_in_buffer(file_path, "m_todo_Finished:", "m_todo_Finished: " .. new_date)
      file_times_map[file_path]["m_todo_Finished"] = new_date
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

F.map("n", F.format_os_altkey("<C-%s-`>"),
  function()
    local file_path
    if F.get_todo() ~= "" then
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
