-- to run :luafile %
local M = {}
local date_time_format ='%Y-%m-%d %H:%M'

local function get_time(current_line)
  local capture_time = current_line:match('@c%(([^)]+)%)')
  local start_time = current_line:match('@s%(([^)]+)%)')
  local finished_time = current_line:match('@f%(([^)]+)%)')
  return capture_time , start_time , finished_time
end

local function format_duration(diff_seconds)
  if diff_seconds >= 86400 then
    local days = diff_seconds / 86400
    return string.format("%.1f days", days)
  elseif diff_seconds >= 3600 then
    local hours = diff_seconds / 3600
    return string.format("%.1f hours", hours)
  else
    local minutes = diff_seconds / 60
    return string.format("%.1f minutes", minutes)
  end
end

local function calc_time(m_date1, m_date2)
  -- Using Vim's strptime if available
  local t1 = vim.fn.strptime(date_time_format, m_date1)
  local t2 = vim.fn.strptime(date_time_format, m_date2)
  return format_duration(t2 - t1)
end

function M.advance_todo_time()
  local current_line = vim.api.nvim_get_current_line()
  if M.todo_line_check(current_line) == "" then
    vim.notify("Not a well-formed todo line", vim.log.levels.ERROR)
    return
  end

  local capture_time, start_time, finished_time = get_time(current_line)
  if capture_time == nil then
    vim.notify("There is no capture time", vim.log.levels.ERROR)
    return
  elseif start_time == nil then
    local new_line = string.format("%s @s(%s)",current_line, os.date(date_time_format))
    vim.api.nvim_set_current_line(new_line)
    return
  elseif finished_time == nil then
    finished_time = os.date(date_time_format)
    local elapsed_time = calc_time(start_time, finished_time)
    current_line = current_line:gsub("^%- %[ %]", "- [x]")

    local new_line = string.format("%s @f(%s) @e(%s)",current_line, finished_time, elapsed_time)
    vim.api.nvim_set_current_line(new_line)
    vim.g.m_todo=""
    return
  else
    vim.notify("Task is DONE")
  end
end

function M.todo_line_check(todo_line)
  todo_line = vim.trim(todo_line)
  if string.match(todo_line, "^%-.*@c") then
    return todo_line:gsub("^%-", "- [ ]")
  else
    return ""
  end
end

local function match_single_link(str, suppressed_notify)
  suppressed_notify = suppressed_notify or false
  local count = 0
  local first_text, first_url

  -- Iterate through all markdown links in the string
  for text, url in str:gmatch("%[([^%]]+)%]%(([^)]+)%)") do
    count = count + 1
    first_text, first_url = vim.trim(text), vim.trim(url)
  end

  if count == 1 then
    return first_text, first_url
  elseif suppressed_notify then
    return
  elseif count == 0 then
    vim.notify("No Markdown Link found", vim.log.levels.ERROR)
  else
    vim.notify(string.format("Multiple Markdown links found: %s", count), vim.log.levels.ERROR)
  end
  return nil, nil
end

local function create_file(filepath, first_line)
  -- Open file in write-only mode; creates it if it doesn't exist
  filepath = vim.fn.expand(filepath)
  local fd = vim.uv.fs_open(filepath, "w", 438)
  if fd then
    vim.uv.fs_write(fd, "# "..first_line, 0)
    vim.uv.fs_close(fd)
    vim.notify("File created: " .. vim.fn.fnamemodify(filepath, ":t"))
    return true
  else
    vim.notify("Error: Could not create file:" .. filepath, vim.log.levels.ERROR)
    return false
  end
end

function M.md_follow_link()
  local current_line = vim.api.nvim_get_current_line()
  local text, url =match_single_link(current_line)
  if text~=nil and url~=nil then
    if vim.startswith(url, "http") then
      vim.cmd("fclose!")
      vim.ui.open(url)
      return
    else
      local path = vim.fn.expand(url)
      local stat =vim.uv.fs_stat(path)
      if stat == nil then
        vim.notify("Invalid path:" .. path, vim.log.levels.ERROR)
        return
      end
      if stat and stat.type=="file" then
        vim.cmd.edit(path)
        vim.cmd("fclose!")
        return
      end
    end
  end
end

function M.md_create_link()
  local current_line = vim.api.nvim_get_current_line()
  local text, url = match_single_link(current_line)
  if text and url then
    vim.notify("Link exists. Can't create new one", vim.log.levels.WARN)
    return
  end
  local m_str = current_line:match("%- %[ %] (.-)@c")
  local uuid = vim.fn.system('uuidgen'):gsub('%s+', '')
  local new_file_name = string.format(vim.g.m_notes_path.."/todo_notes/%s.md", uuid)
  local new_md_link = string.format(" [%s](%s) ", m_str, new_file_name)

  local updated_line = current_line:gsub("(%- %[ %] ).- (@c)", "%1" .. new_md_link .. "%2")
  if create_file(new_file_name, m_str) then
    vim.api.nvim_set_current_line(updated_line)
  end
end

function M.set_todo()
  local current_line = vim.api.nvim_get_current_line()
  local text, url = match_single_link(current_line, true)
  if text==nil and url==nil then
    text = current_line:match("%- %[ %] (.-)@c")
  end
  if text==nil or text=="" then
    vim.notify("Can't find text to set todo")
    return
  end
  vim.g.m_todo = text
  vim.notify("Doing now:" .. text)
end

return M
