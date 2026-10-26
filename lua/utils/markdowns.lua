-- to run :luafile %
local M = {}
local date_time_format ='%Y-%m-%d %H:%M'

function M.get_timestamp(line, letter)
  if line == "" or line == nil then
    vim.notify("line can't be blank", vim.log.levels.ERROR)
    return
  end

  if letter=="" or letter == nil then
    vim.notify("param letter can't be blank", vim.log.levels.ERROR)
    return
  end
  local pattern = "@"..letter.."%(([^)]+)%)"
  return line:match(pattern)
end

function M.get_times(str)
  local capture_time =  M.get_timestamp(str, "c")
  local start_time =    M.get_timestamp(str, "s")
  local finished_time = M.get_timestamp(str, "f")
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

function M.advance_todo_time(current_line)
  local capture_time, start_time, finished_time = M.get_times(current_line)

  if capture_time == nil then
    vim.notify("There is no capture time", vim.log.levels.ERROR)
    return ""
  elseif start_time == nil then
    return string.format("%s @s(%s)",current_line, os.date(date_time_format))
  elseif finished_time == nil then
    finished_time = os.date(date_time_format)
    local elapsed_time = calc_time(start_time, finished_time)
    local new_line = string.format("%s @f(%s) @e(%s)",current_line, finished_time, elapsed_time)
    vim.g.m_todo=""
    return new_line
  else
    vim.notify("Task is DONE")
    return current_line
  end
end

function M.todo_line_check(todo_line)
  if string.match(vim.trim(todo_line), "^%-.*@c") then
    return true
  else
    return false
  end
end

function M.match_single_link(str, suppressed_notify)
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
    return true
  else
    vim.notify("Error: Could not create file:" .. filepath, vim.log.levels.ERROR)
    return false
  end
end

function M.md_follow_link()

end

function M.md_create_link(current_line)
  -- local current_line = vim.api.nvim_get_current_line()
  local text, url = M.match_single_link(current_line, true)
  if text and url then
    vim.notify("Link exists. Can't create new one", vim.log.levels.WARN)
    return
  end
  local m_str = current_line:match("%- (.-)@c")
  local uuid = vim.fn.system('uuidgen'):gsub('%s+', '')
  local new_file_name = string.format(vim.g.m_notes_path.."/todo_notes/%s.md", uuid)
  local new_md_link = string.format("[%s](%s)", m_str, new_file_name)

  local updated_line = current_line:gsub(".- (@c)", new_md_link .. " %1")
  create_file(new_file_name, m_str)
  return updated_line
end

function M.set_todo()
  local current_line = vim.api.nvim_get_current_line()
  local text, url = M.match_single_link(current_line, true)
  if text==nil and url==nil then
    text = current_line:match("%- %[ %] (.-)@c")
  end
  if text==nil or text=="" then
    vim.notify("Can't find text to set todo")
    return
  end
  vim.g.m_todo = text
end

return M
