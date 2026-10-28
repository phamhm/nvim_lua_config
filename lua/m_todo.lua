local F = require('utils.functions')
local M = require('utils.markdowns')

local TODO_FILE_PATH = vim.fn.expand(vim.g.m_notes_path .. "/TODO.md")
local DISCARD_FILE_PATH = vim.fn.expand(vim.g.m_notes_path .. "/archive/discarded_notes.md")
local SAVE_FILE_PATH = vim.fn.expand(vim.g.m_notes_path .. "/archive/save_notes.md")

-- take items that has the item.content, and flatten it
local function flatten_picker_items(items)
  return vim.iter(items)
    :map(function(item) return item.content end)
    :flatten():totable()
end

local function todo_picker(items, title, actions, keys)
  if not actions then
    vim.notify("No actions for picker", vim.log.levels.ERROR)
    return
  end

  if not items or #items==0 then
    vim.notify("No item to pick")
    return
  end

  Snacks.picker.pick({
    source = "markdown_links",
    items = items,
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
        keys = {
          ["<C-h>"] = { "m_focus_list", mode = {"n"}},
          ["<C-s>"] = { "save_preview", mode = {"i", "n"}},
          ["<C-j>"] = { "m_list_down", mode = {"n"}},
          ["<C-k>"] = { "m_list_up", mode = {"n"}},
          ["i"] = {function() vim.cmd("startinsert") end , mode = {"n"}} -- have to define it here, default value enter input window
        },
        wo = {
        }
      },
    },
    preview = actions.fn_preview,
    confirm = actions.fn_confirm,
  })
end

local function _move_code(moving_indices, items, from_path, to_path)
  local move_lines = vim.iter(items)
    :filter(function(item) return vim.list_contains(moving_indices, item.idx) end)
    :map(function(item) return item.content end)
    :flatten():totable()

  local save_lines = vim.iter(items)
    :filter(function(item) return not vim.list_contains(moving_indices, item.idx) end)
    :map(function(item) return item.content end) -- create a list of content without the meta data
    :flatten():totable() -- turn a list of lists into a list of strings


  -- update the the from file with the saved lines
  if vim.fn.writefile(save_lines, vim.fn.expand(from_path)) ~= 0 then
    vim.notify("Failed to write to file:"..from_path)
    return
  end

  -- append  the to_move lines into the to_move files md
  if vim.fn.writefile(move_lines, vim.fn.expand(to_path), "a") ~=0 then
    vim.notify("Failed to write to file:" .. to_path)
    return
  end
  vim.notify("Item moved to "..to_path)
end

local function get_heading(bufnr, heading)
  local query_string = [[
  (section
    (atx_heading
      (atx_%s_marker)
    ) @%s_marker
  ) @%s_section
]]
  query_string = string.format(query_string, heading, heading, heading)

  bufnr = bufnr or 0
  local parser = vim.treesitter.get_parser(bufnr, 'markdown')
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = vim.treesitter.query.parse('markdown', query_string)
  local results = {}

  for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
    local capture_name = query.captures[id]
    if capture_name == 'h1_section' then
      local start_row, _, end_row, _ = node:range()
      local text = vim.treesitter.get_node_text(node, bufnr)
      text = vim.split(text, "\r?\n", { plain = false })

      table.insert(results, text)
    end
  end

  return results
end

function todo()
  vim.cmd("fclose")
  -- opening a headless buffer
  local bufnr = vim.fn.bufadd(TODO_FILE_PATH)
  vim.fn.bufload(bufnr)

  items = {}
  for _, heading in ipairs(get_heading(bufnr, "h1")) do
    local item = {
      text = string.sub(heading[1], 3),
      link = TODO_FILE_PATH,
      raw_heading = string.sub(heading[1], 3),
      content = heading -- contain what tree sitter return
    }
    table.insert(items, item)
  end
  vim.api.nvim_buf_delete(bufnr, {force = true}) -- close the tmp buffer

  for _, item in ipairs(items) do
    local datetime_line = item.content[2]
    local _, s_time, f_time = M.get_times(datetime_line)
    if f_time then
      item.text = " "..item.text
    elseif s_time then
      item.text = " "..item.text
    end
  end

  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
    vim.notify("No todo item", vim.log.levels.WARN)
    return
  end

  local m_actions = {
    hidden = {"input"},
  }

  function m_actions.save_preview (picker, item)
    if picker.preview and picker.preview.win and picker.preview.win:valid() then
      local win_id = picker.preview.win.win
      local preview_bufnr = vim.api.nvim_win_get_buf(win_id)

      -- 2. Check if the buffer is valid
      if vim.api.nvim_buf_is_valid(preview_bufnr) then
        -- 3. Read all lines from the preview buffer (0 to -1 means everything)
        local new_content = vim.api.nvim_buf_get_lines(preview_bufnr, 0, -1, false)

        if not vim.deep_equal(new_content, item.content) then
          picker.list.items[item.idx].content = new_content
          picker.list:update({ force = true })

          local file_lines = flatten_picker_items(picker.list.items)
          if vim.fn.writefile(file_lines, vim.fn.expand(TODO_FILE_PATH)) == 0 then
            vim.notify("Saved preview content")
          else
            vim.notify("Failed to write new preview to ".. TODO_FILE_PATH)
          end
        else
          vim.notify("Same content. Not saved")
        end
      end
    else
      vim.notify("Preview window is not open or active.", vim.log.levels.WARN)
    end
  end

  function m_actions.m_focus_list(picker, item)
    m_actions.save_preview(picker, item)
    Snacks.picker.actions.focus_list(picker)
  end

  function m_actions.m_list_up(picker, item)
    m_actions.save_preview(picker, item)
    Snacks.picker.actions.list_up(picker)
  end

  function m_actions.m_list_down(picker, item)
    m_actions.save_preview(picker, item)
    Snacks.picker.actions.list_down(picker)
  end

  function m_actions.move_notes(picker, item)
    local items = picker:selected({ fallback = true })
    local moving_indices = vim.iter(items):map(function(i) return i.idx end):totable()
    _move_code(moving_indices, picker.list.items, TODO_FILE_PATH, SAVE_FILE_PATH)

    picker.list.items = vim.iter(picker.list.items)
      :filter(function(item) return not vim.list_contains(moving_indices, item.idx) end):totable()
    picker.list:update({ force = true })
  end

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

  function m_actions.advance_time(picker, item)
    local items = picker:selected({ fallback = true })
    if #items>1 then
      vim.notify("Can't advance time on multiple items")
      return
    end

    local datetime_line = item.content[2]
    local current_f_time = M.get_timestamp(datetime_line, "f")
    if current_f_time then
      vim.notify("Task is DONE")
      if item.text == F.get_todo() then
        F.clear_todo()
      end
      return
    end

    local new_datetime_line = M.advance_todo_time(datetime_line)
    item.content[2] = new_datetime_line -- update the the new time. also update picker.list.items
    local _, s_time, f_time = M.get_times(new_datetime_line)

    if f_time then
      vim.notify("Task is DONE")
      if item.text == F.get_todo() then
        F.clear_todo()
      end
      item.text = " "..vim.fn.strcharpart(item.text, 2) -- must be strcharpart because unicode first character
    elseif s_time then
      vim.notify("Starting:" .. item.text)
      F.set_todo(item.raw_heading)
      item.text = " "..item.text
    end

    if date_line == new_datetime_line then
      return
    end

    picker.list.items[item.idx] = item
    picker.list:update({ force = true })

    local file_lines = flatten_picker_items(picker.list.items)

    if vim.fn.writefile(file_lines, vim.fn.expand(TODO_FILE_PATH)) ~= 0 then
      vim.notify("Failed to write to ".. TODO_FILE_PATH)
    end

    -- currently not in preview window. must check if there is an preview number to reload it
    if picker and picker.preview and picker.preview.win:valid() then
      local preview_buf = vim.api.nvim_win_get_buf(picker.preview.win.win)
      F.update_picker_preview(preview_buf, item.content)
    end
  end

  function m_actions.discard_notes(picker, item)
    F.clear_todo()
    local items = picker:selected({ fallback = true })
    local moving_indices = vim.iter(items):map(function(i) return i.idx end):totable()
    _move_code(moving_indices, picker.list.items, TODO_FILE_PATH, DISCARD_FILE_PATH)

    picker.list.items = vim.iter(picker.list.items)
      :filter(function(item) return not vim.list_contains(moving_indices, item.idx) end):totable()
    picker.list:update({ force = true })
  end

  function m_actions.fn_preview(picker)
    if picker.preview and picker.preview.win then
      vim.bo[picker.buf].filetype = "markdown"
      vim.bo[picker.buf].modifiable = true
      vim.bo[picker.buf].readonly = false

      pcall(function()
        require("render-markdown").enable(picker.buf)
      end)
      vim.api.nvim_buf_set_lines(picker.buf, 0, -1, false, picker.item.content)
    end
  end

  local m_keys = {
    ["<C-a>"] = { "advance_time", mode = {"i", "n"}},
    ["<C-t>"] = { "set_todo", mode = {"i", "n"}},
    ["<C-m>"] = { "move_notes", mode = {"i", "n"}},
    ["<C-x>"] = { "discard_notes", mode = {"i", "n"}},
    ["<C-l>"] = { "focus_preview", mode = {"n"}},
  }
  local actions, keys = F.gen_picker_actions(nil, m_actions, m_keys)
  todo_picker(items, "Select TODO item(s)", actions, keys)
end

F.map("n", "<C-`>", todo, {desc = "calling todo"})
