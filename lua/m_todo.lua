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

local function read_first_line(filename)
  for line in io.lines(vim.fn.expand(filename)) do
    return line
  end
end

local function read_json_first_line(filename)
  local first_line = read_first_line(filename)
  return vim.json.decode(first_line)
end

-- replace the first instance of old text with new text
-- if there are multiple instances of old text, only the first one get replaced
local function replace_first_in_buffer(filepath, line)
  -- Expand system paths like ~/ or $HOME
  local expanded_path = vim.fn.expand(filepath)

  if vim.fn.filereadable(expanded_path) == 0 then
    vim.notify("Error: File not found: " .. expanded_path, vim.log.levels.ERROR)
    return
  end

  -- 1. Create a hidden background buffer and load the file lines into it
  local bufnr = vim.fn.bufadd(expanded_path)
  vim.fn.bufload(bufnr)

  vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { line })
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("silent update")
  end)
  vim.api.nvim_buf_delete(bufnr, { force = true })
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
    -- confirm = actions.fn_confirm,
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

        local file_path = item.cwd .. '/' .. item.file
        local config_json = read_json_first_line(file_path)
        item.text = config_json.Title
        local started = config_json.Started
        item.started = started and vim.trim(started)
        local finished = config_json.Finished

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
    local meta_info = read_json_first_line( file_path )
    local started = meta_info.Started
    local finished = meta_info.Finished
    local new_date = os.date("%Y-%m-%d %H%M")
    local todo = item.text
    if started and started == "" then
      meta_info.Started = new_date
      local meta_json = vim.json.encode(meta_info)
      replace_first_in_buffer(file_path, meta_json)
      m_actions.set_todo(picker, item)
    elseif finished and finished == "" then
      meta_info.Finished = new_date
      local meta_json = vim.json.encode(meta_info)
      replace_first_in_buffer(file_path, meta_json)
      if todo == F.get_todo() then
        F.clear_todo()
      end
    end

    picker:refresh()
  end

  -- function m_actions.fn_confirm(picker, item)
  --   picker:close()
  --   Snacks.scratch.open({file = item._path, name = item.text})
  -- end

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
