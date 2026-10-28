local F = require('utils.functions')

local TODO_FILE_PATH = vim.fn.expand(vim.g.m_notes_path .. "/TODO")

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

  Snacks.picker.files({
    exclude = {"DONE/", "DISCARDED/"},
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
  })
end

function todo()
  vim.cmd("fclose")
  -- opening a headless buffer

  local todo_iter = vim.fs.dir(TODO_FILE_PATH)
  local items = vim.iter(todo_iter)
    :map(function(name, ft)
      if ft == "file" then
        return {
          text = name:gsub("%.md$", ""):gsub("-", " "),
          link = TODO_FILE_PATH .. '/' .. name,
        }
      end
    end):totable()

  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
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

  function m_actions.fn_confirm(picker, item)
    picker:close()
    Snacks.scratch.open({file = item._path, name = item.text})
  end

  local m_keys = {
    ["<C-j>"] = { "list_down", mode = {"i", "n"}},
    ["<C-k>"] = { "list_up", mode = {"i", "n"}},
    ["<C-f>"] = { "done_notes", mode = {"i", "n"}},
    ["<C-x>"] = { "discard_notes", mode = {"i", "n"}},
    ["<C-w>l"] = { "focus_preview", mode = {"n"}},
  }
  local actions, keys = F.gen_picker_actions(nil, m_actions, m_keys)
  todo_picker(items, "Select TODO item(s)", actions, keys)
end

F.map("n", "<C-`>", todo, {desc = "calling todo"})
