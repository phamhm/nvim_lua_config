local F = {}

function F._inspect(obj)
  vim.notify(vim.inspect(obj))
end

local custom_key_maps = {}

function F.save_keys(key)
  if not vim.tbl_contains(custom_key_maps, key) then
    table.insert(custom_key_maps, key)
  end
end

function F.map(mode, lhs, rhs, opts)
  if opts == nil then
    opts = {silent = true, noremap = true}
  else
    if opts.silent == nil then
      opts.silent = true
    end
    if opts.noremap == nil then
      opts.noremap = true
    end
  end

  local key = lhs ..":".. (opts and opts.desc or "no description")
  F.save_keys(key)
  vim.keymap.set(mode, lhs, rhs, opts)
end

function F.get_keys()
  return MiniAlign.align_strings(custom_key_maps, {split_pattern=':'})
end

-- take note_text and write to destination with @c capture time


function F.format_os_altkey(key_formatter, repeat_n)
  repeat_n = repeat_n or 1
  -- example <C-%s-j> will return <C-D-j> on osx and <C-M-j> on everything else
  local md_key = jit.os == "OSX" and "D" or "M"
  local key = string.format(key_formatter, md_key)

  return string.rep(key, repeat_n)
end

function F.menu_commands(items, title)
  Snacks.picker.pick({
    pattern="^",
    items = items,
    title = title,
    format = "text",
    layout = {
      preview = false,
      layout = {
        width = 0.3,
        height = 0.5,
      }
    },
    confirm = function(picker, item)
      picker:close()
      if item and item.fn then
        item.fn()
      end
    end,
    matcher = {
      fuzzy = false, -- use fuzzy matching
      smartcase = true, -- use smartcase
      ignorecase = true, -- use ignorecase
      sort_empty = false, -- sort results when the search string is empty
      filename_bonus = true, -- give bonus for matching file names (last part of the path)
      file_pos = true, -- support patterns like `file:line:col` and `file:line`
      -- the bonusses below, possibly require string concatenation and path normalization,
      -- so this can have a performance impact for large lists and increase memory usage
      cwd_bonus = false, -- give bonus for matching files in the cwd
      frecency = false, -- frecency bonus
    },
  })
end

local function picker_list_files(m_path)
  local items = {} -- must be first line

  local dir_path = vim.fn.expand(m_path)
  local handle = vim.uv.fs_scandir(dir_path)
  if handle then
    while true do
      local name, type = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end

      if type == 'file' and
        (vim.endswith(name, ".zsh") or
        vim.endswith(name, ".applescript") or
        vim.endswith(name, ".rdp")) then
        local full_path = dir_path ..  vim.trim(name)
        table.insert(items, {
          text = "script:" .. vim.trim(name),    -- What shows up and is searchable in the picker
          link = vim.trim(full_path),     -- Store the URL to use on confirmation
        })
      end
    end
  end
  return items
end

-- if item is an .com, then open it.
-- if applescript, call osascript to execute
-- .zsh, then open a new kitty tab to execute the code there
-- if text contains the word "edit" and the link is a readable file, then open it.
function F.open_md_link(md_link_item)
  -- item must contain item.link and item.text
  if not (md_link_item and md_link_item.link and md_link_item.text) then
    vim.notify("Item elements are missing")
    return
  end

  local cmd
  if type(md_link_item.link) == "function" then
    md_link_item.link()
    return true
  elseif vim.startswith(md_link_item.link, "http") or
         vim.endswith(md_link_item.link, ".rdp") or
         vim.startswith(md_link_item.link,"msteams:/") or
         vim.startswith(md_link_item.link,"slack:/") then
    vim.ui.open(md_link_item.link) -- Open the link using your system's default handler
    return true
  elseif  vim.endswith(md_link_item.link, ".applescript") then
    cmd = {"osascript", vim.fn.expand( md_link_item.link )}
  elseif  vim.endswith(md_link_item.link, ".zsh") then
    cmd = {
      'kitten',
      '@',
      '--to',
      os.getenv("KITTY_LISTEN_ON"),
      'launch',
      '--type=tab',
      'zsh',
      '-f',
      vim.fn.expand( md_link_item.link ),
    }
  elseif vim.fn.filereadable(vim.fn.expand(md_link_item.link)) == 1 then
    local file_path = vim.fn.expand(md_link_item.link)
    vim.cmd.edit(file_path)
    return true
  else
    vim.notify("Unexpected format " .. md_link_item.text .. ":" .. md_link_item.link, vim.log.levels.ERROR)
    return nil
  end
  if type(cmd) == "table" and next(cmd) ~= nil then
    vim.system(cmd, { detach = true}, function(err)
      if err and err.code ~= 0 then
        vim.schedule(function()
          vim.notify("Failed to run:" .. vim.inspect(err), vim.log.levels.ERROR)
        end)
      end
    end)
    return true
  end
  return nil
end

function F.update_picker_preview(buf, preview)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, preview)
end


function F.get_mdlink_lines(filepath)
  local items = {} -- must be first line

  -- 1. Define the path to your file
  local bookmark_file_path = vim.fn.expand(filepath) -- Change this to your file path
  -- 2. Read lines from the file
  local lines = vim.fn.readfile(bookmark_file_path)

  -- 3. Parse each line for the [title](link) format
  for _, line in ipairs(lines) do
    local title, link = line:match("%[(.-)%]%((.-)%)")
    if title and link then
      table.insert(items, {
        text = vim.trim(title),    -- What shows up and is searchable in the picker
        link = vim.trim(link),     -- Store the URL to use on confirmation
        raw  = line
      })
    end
  end
  return items
end

function F.set_todo(todo)
  vim.g.m_todo = todo
end

function F.get_todo()
  return vim.g.m_todo
end

function F.clear_todo()
  if vim.g.m_todo ~="" then
    vim.notify("Clear todo:" .. vim.g.m_todo)
  end
  vim.g.m_todo = ""
end

function F.set_status(msg)
  vim.g.global_status = msg
end

function F.clear_status()
  vim.g.global_status = ""
end

-- generate a keys and actions to handle multiple items.
-- if you pass in anything that need access to the list, user must provide that object with the m_actions.
-- otherwise, m_actions methods won't be able to access the same picker_items list from this scope
function F.gen_picker_actions(fn_items_handler, m_actions, m_keys)
  fn_items_handler = fn_items_handler or function(bookmarks)
    for _, bookmark in ipairs(bookmarks) do
      F.open_md_link(bookmark)
    end
  end

  -- keep this empty for now.
  -- not deleting in case I want to have a default keys in the future
  local keys ={}

  local actions = {
    fn_confirm = function(picker, _)
      picker:close()
      local items = picker:selected({ fallback = true })
      fn_items_handler(items)
    end,

    fn_preview = function(picker)
      local preview = {
        string.format("Action: %s", picker.item.link),
        "",
      }

      F.update_picker_preview(picker.buf, preview)
    end,
  }

  -- if key collision like same function name, m_actions will override actions
  if m_actions then
    actions = vim.tbl_deep_extend("force", actions, m_actions)
  end
  if m_keys then
    keys = vim.tbl_deep_extend("force", keys, m_keys)
  end

  return actions, keys
end

-- this function will read from the notes/bookmarkds.md
-- AND the scripts in Documents/scripts
-- build a list of {text, link}
function F.generate_bookmarks_picker()
  vim.cmd("fclose")
  local items = F.get_mdlink_lines(vim.g.m_notes_path .. "/bookmarks.md")

  vim.list_extend(items, picker_list_files(vim.g.m_scripts))

  -- 4. Open the Snacks picker if we found any links
  if #items == 0 then
    vim.notify("No valid Markdown links found in the file", vim.log.levels.WARN)
    return
  end

  local actions, keys = F.gen_picker_actions()

  F.m_picker(items, "Select Bookmark(s) to open",actions, keys)
end



-- my custom Snacks.picker.pick for multiple selections
-- User can do multiple selection, and executes all at once
-- default fn_item_handler is the open_item function
function F.m_picker(items, title, actions, keys)
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
      hidden = actions.hidden or {"preview", "input"},
      layout = {
        min_width = 0,
        width = 0.3,
        height =  0.5,
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
    },
    preview = actions.fn_preview,
    confirm = actions.fn_confirm,
  })
end

function F.set_title()
  local fname = vim.fn.expand('%:t')
  if not (fname and fname~="") then
    return "[no file]"
  end
  -- local icon = MiniIcons.get('file', fname).. ' '

  fname = vim.fn.expand('%:p:h:t')..'/' .. fname

  local session = vim.trim(vim.v.this_session)
  if session~="" then
    session = vim.fs.basename(vim.v.this_session).."::"
  else
    session = ""
  end

  local readonly = vim.bo[0].readonly and "[]" or " "
  local modified = vim.bo[0].modified and "[]" or " "

  return string.format("%s%s %s%s", session, fname, modified , readonly)
end

return F
