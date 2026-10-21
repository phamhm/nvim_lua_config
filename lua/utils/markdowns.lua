-- to run :luafile %
local M = {}

local function get_time(current_line)
  local capture_time = current_line:match('@c%(([^)]+)%)')
  local start_time = current_line:match('@s%(([^)]+)%)')
  local finished_time = current_line:match('@f%(([^)]+)%)')
  return capture_time , start_time , finished_time
end

local date_time_format ='%Y-%m-%d %H:%M'

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

local function start_todo_time()
  local current_line = vim.api.nvim_get_current_line()
  local capture_time, start_time, finished_time = get_time(current_line)

  if not (current_line:match("^## ")) then
    vim.notify("Not a TODO heading", vim.log.levels.ERROR)
    return
  elseif capture_time == nil then
    vim.notify("Capture time missing", vim.log.levels.ERROR)
    return
  elseif start_time ~= nil then
    vim.notify("Todo item alread started", vim.log.levels.ERROR)
    return
  elseif finish_time ~= nil then
    vim.notify("Todo item alread finished", vim.log.levels.ERROR)
    return
  end

  local new_line = string.format("%s @s(%s)",current_line, os.date(date_time_format))

  vim.api.nvim_set_current_line(new_line)
end

local function complete_todo_time()
  local current_line = vim.api.nvim_get_current_line()
  local capture_time, start_time, finished_time = get_time(current_line)

  if not (current_line:match("^## ")) then
    vim.notify("Not a TODO heading", vim.log.levels.ERROR)
    return
  elseif capture_time == nil then
    vim.notify("Capture time missing", vim.log.levels.ERROR)
    return
  elseif start_time == nil then
    vim.notify("Todo item NOT started", vim.log.levels.ERROR)
    return
  elseif finished_time ~= nil then
    vim.notify("Todo item alread finished", vim.log.levels.ERROR)
    return
  end

  finished_time = os.date(date_time_format)
  local elapsed_time = calc_time(start_time, finished_time)

  local new_line = string.format("%s @f(%s) @e(%s)",current_line, finished_time, elapsed_time)
  vim.api.nvim_set_current_line(new_line)
end


-- vim.keymap.set("n", "<leader>tt", function() start_todo_time() end, {})
-- vim.keymap.set("n", "<leader>tf", function() complete_todo_time() end, {})
--
--

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




return M
