local F = require("utils.functions")

-- disable autocompletion in the windows. will work on vim.ui.open
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"snacks_picker", "snacks_picker_input", "snacks_input"}, -- "snacks_input""snacks_picker_input",
  callback = function()
    vim.b.minicompletion_disable = true
  end,
})

-- TODO: how to make multiple dirs readable
local function m_set_title(picker, item)
  if picker and picker.list and picker.list.win then
    local source = picker.init_opts.source
    local dirs = picker.opts.dirs
    if vim.list_contains({"grep", "explorer"}, source) then
      if dirs and #dirs == 1 then
        local f = unpack(dirs)
        f = vim.fn.fnamemodify(f, ":~")
        picker.list.win:set_title(f)
      elseif dirs and #dirs > 1 then
        print("Multiple Dirs:\n" .. table.concat(dirs, "\n"))
        picker.list.win:set_title("Multiple Dirs")
      else
        local f = item and item._path or picker:cwd()
        f = vim.fn.fnamemodify(f, ":~")
        picker.list.win:set_title(f)
      end
    end
  end
end

-- Picker explorer actions
local function m_tcd(picker, item)
  Snacks.picker.actions.tcd(picker, item)
  m_set_title(picker, item)
end

local function m_explorer_up(picker, item)
  local explorer_actions = require("snacks.explorer.actions").actions
  explorer_actions.explorer_up(picker)
  m_set_title(picker)
end

local function m_list_up(picker, item)
  local idx = item.idx - 1
  if idx == 0 then
    idx = #picker.finder.items
  end

  local next_item = picker.finder.items[idx]
  m_set_title(picker, next_item)
  Snacks.picker.actions.list_up(picker, item)
end

local function m_list_down(picker, item)
  local idx = item.idx + 1
  local next_item =picker.finder.items[idx]
  m_set_title(picker, next_item)
  Snacks.picker.actions.list_down(picker, item)
end

local function move_selected(picker, item)
  local selected = vim.iter(picker:selected()):map(function(selected) return selected._path end):totable()
  local current_path = item._path

  local current_path_dir = item._path
  if vim.uv.fs_stat(current_path_dir).type == "file" then
    current_path_dir = vim.fs.dirname(current_path_dir)
  end

  local prompt = string.format("Move %s file(s) to %s :\n\n%s", #selected,current_path_dir, table.concat(selected, "\n") )

  local choice = vim.fn.confirm(prompt, "&Yes\n&No", 1)
  if choice == 1 then
    vim.iter(selected):each(
      function(old_path)
        local from = old_path

        local from_path = vim.fs.dirname(from)
        local filename = vim.fs.basename(from)

        local to = current_path_dir .. "/" .. filename

        Snacks.rename.rename_file({
          from = from,
          to = to
        })
      end)

    local Tree = require("snacks.explorer.tree")
    Tree:refresh(current_path_dir)
    Tree:open(current_path_dir)
    picker:refresh()
  end
end

local function m_explorer_root(picker, item)
  local markers = { '.git' }

  local current_cwd = picker.init_opts.cwd
  local root = vim.fs.root( current_cwd, markers )
  F.NOTIFY("root :" .. root)

  picker:set_cwd(root)
  picker:find()
end

local function m_todo_from_root()
  local todos = {"TODO", "FIXME"}
  local todo_keys = vim.iter(todos)
    :map(function(i) return i .. ":" end)
    :totable()
  local current_cwd = vim.fn.expand("%:p")

  local markers = { '.git' }
  local root = vim.fs.root( current_cwd, markers )
  if root and vim.uv.fs_stat(root) then
    Snacks.picker.grep({
      search = table.concat(todo_keys, "|"),
      cwd = root,
      layout = {
        hidden = {'input', 'preview'}
      },
      on_show = function(picker)
        picker.list.win:set_title("TODO Root:" .. root)
      end,
      format = function(item, picker)
        local ret = {}
        local m_todo
        local m_msg
        local todo_len = 5
        local msg_len = 50
        for _, todo in ipairs(todos) do
          if item.line:upper():match(todo..":") then
            local t = vim.split(item.line, todo .. ":")
            t = vim.list_slice(t, 2)
            m_msg = table.concat(t, " ")
            m_msg = m_msg .. string.rep(" ", math.max(0, msg_len - #m_msg))
            m_todo = todo .. string.rep(" ", math.max(0, todo_len - #todo))
            break
          end
        end

        if not m_todo or m_todo == "" then
          F.WARN("unrecognizable m_todo")
          picker:close()
          return {}
        end

        local hlgroup
        if m_todo:match("TODO") then
          hlgroup = "TodoHl" -- DONE: not picking up the red TodoHl group. why?
        elseif m_todo:match("FIXME") then
          hlgroup = "FixmeHl"
        end
        ret[#ret + 1] = { m_todo or "", hlgroup }
        ret[#ret + 1] = { m_msg or "", "Normal" }
        ret[#ret + 1] = { " " ..item.file or "", "Comment" }
        return ret
      end,
    })
  end
end

local function diff_selected(picker)
  picker:close()
  local selected = picker:selected()
  if #selected == 2 then
    vim.cmd("tabnew " .. selected[1].file)
    vim.cmd("vert diffs " .. selected[2].file)
    Snacks.notify.info("Diffing " .. selected[1].file .. " & " .. selected[2].file)
  else
    F.WARN("Need 2 files to diff. Found " .. #selected)
  end
end

local function zip_selected(picker, item)
  local path_to_files = vim.fn.fnamemodify(item._path, ":h")

  local filenames = vim.iter(picker:selected({fallback = true}))
    :map(function(i) return i._path end)
    :totable()

  vim.ui.input({prompt = "tar file name"},
    function(tar_name)
      picker:close()
      F.tar_files(tar_name, filenames)
    end
  )
end

local function m_grep(picker, item)
  local selected = vim.iter(picker:selected({fallback = true}))
    :map(function(i)
      if picker.opts.source == "grep" then
        local line =  vim.trim(i.line)
        if vim.startswith(line, "-") then
          line = line:gsub("^-", "")
          line = vim.trim(line)
        end
        return line
      else
        return i._path or i.item or i.text
      end
    end)
    :filter(
      function(path)
        path = vim.trim(path)
        local fs_stat = vim.uv.fs_stat(vim.fn.expand(path))
        return fs_stat and vim.list_contains({"file", "directory"}, fs_stat.type)
      end)
    :totable()

  if #selected > 0 then
    vim.cmd("fclose!")
    if #selected == 1 then
      Snacks.picker.grep({
        cwd = unpack(selected),
      })
    else
      Snacks.picker.grep({
        dirs = selected,
      })
    end
  else
    F.ERROR("Didn't select a file/directory to Grep")
  end
end

local m_actions = {
  m_grep = m_grep
}

local m_grep_actions = {
  m_cd_up = function(picker, item)
    local current_cwd
    if picker.opts.cwd then
      current_cwd = picker.opts.cwd
    elseif picker.opts.dirs then
      F.ERROR("Can only go up with cwd, not dirs")
      return
    else
      F.ERROR("Expected picker.opts.cwd/dirs, found none")
      return
    end

    local new_cwd = vim.fs.dirname(current_cwd)
    F.NOTIFY("Changing cwd to " .. new_cwd)
    picker:set_cwd(new_cwd)
    picker:find()
    m_set_title(picker)
  end,

  m_cd_root = function(picker, item)
    local markers = { '.git', 'app.py', 'package.json', ".env"}

    local current_cwd = picker.init_opts.cwd

    local current_cwd
    if picker.opts.cwd then
      current_cwd = picker.opts.cwd
    elseif picker.opts.dirs then
      F.ERROR("Can only go up with cwd, not dirs")
      return
    else
      F.ERROR("Expected picker.opts.cwd/dirs, found none")
      return
    end

    local root = vim.fs.root( current_cwd, markers )

    F.NOTIFY("Cd to root: " .. root)

    picker:set_cwd(root)
    picker:find()
    m_set_title(picker)
  end
}
local m_grep_keys = {
  [F.alt_key("<%s-u>")] = {"m_cd_up", mode = {"i", "n"}},
  [F.alt_key("<%s-r>")] = {"m_cd_root", mode = {"i", "n"}},
}

local m_keys = {
  [F.alt_key("<%s-p>")] = { "toggle_preview", mode = { "i", "n" } },
  ["<C-c>"] = { "close", mode = { "i", "n" } },
  ["<C-q>"] = { "close", mode = { "i", "n" } },
  ["<C-tab>"] = { "list_down", mode = { "i", "n" } },
  ["<C-S-tab>"] = { "list_up", mode = { "i", "n" } },
  ["<C-g>"] = { "m_grep", mode = { "i", "n" } },
}

local m_snacks = {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    image = {enabled = true, doc = { inline = true , float = true}},
    lazygit = {
      -- Override default theme colors mapped from Neovim highlights
      theme = {
        activeBorderColor = { fg = "MatchParen", bold = false },
        inactiveBorderColor = { fg = "Comment" },
      },
     win = {
        width = 0.9,
        height = 0.9,
      },
    },
    scratch = { enabled = false, root = "/tmp/"},
    explorer = {enabled = true, trash = true},
    bigfile = { enabled = true },
    indent = {
      enabled = true,
      indent = { only_scope = true },
      chunk = { enabled = true },
      animate = { enabled = false}
    },
    input = { enabled = true  },
    terminal = { enable = false, },
    notifier = {
      enabled = true,
      timeout = 5000,
    },
    picker = {
      on_show = function(picker)
        m_set_title(picker)
      end,
      enabled = true ,
      hidden=true,
      sources = {
        lsp_symbols = {
          layout = {
            -- hidden = {"preview"},
            preset = "sidebar",
          },
        },
        grep = {
          actions = m_grep_actions,
          win = {
            input = { keys = m_grep_keys },
            list = { keys = m_grep_keys },
          },
          layout = {
            hidden = {"preview"},
          }
        },
        select = {
          -- Set the layout preset (e.g., "select", "dropdown", "ivy", "vscode", "telescope")
          layout = {
            -- hidden = {"preview", "input"},
            layout = {
              box = "vertical",
              min_width = 0,
              width = 0.3,
              height = 0.4,
              backdrop = false,
              border = "none",
              title = " {title} {live} {flags}",
              -- align = "left",
              -- title_pos = "left",
              { win = "input", height = 1, border = "rounded" },
              {
                box = "horizontal",
                { win = "list", border = "rounded", title="{title}" },
                { win = "preview", title = "{preview}", width = 0.6, border = "rounded" },
              },
            }
          },
          focus = 'list',
        },
        explorer = {
          auto_close = true,
          actions = {
            zip_selected  = zip_selected,
            diff_selected = diff_selected,
            m_tcd         = m_tcd,
            m_explorer_up = m_explorer_up,
            move_selected = move_selected,
            list_up = m_list_up,
            list_down = m_list_down,
            m_explorer_root = m_explorer_root
          },
          win = {
            list = {
              keys = {
                ["Z"]     = { 'zip_selected', mode  = { "n" } },
                ["<C-c>"] = { 'cancel', mode        = { "n", 'i' } },
                ["D"]     = { 'diff_selected', mode = { "n" } },
                ["<C-h>"] = { 'm_explorer_up', mode = { "n" } },
                ["<C-l>"] = { "m_tcd", mode         = { "n" } },
                ["M"]     = { "move_selected", mode = { "n" } },
                [F.alt_key("<%s-r>")] = { "m_explorer_root", mode = { "n" } },
              }
            }
          },
          focus = "input",
          layout = {
            hidden = {"preview"},
          }
        },
        files = {
          focus = {},
          layout = {
            hidden = {},
          },
          exclude = {
            ".git",
            "node_modules",
            ".env",
            "target",
            "build",
            "archive",
            "assets",
            ".*env*",
            "*env*",
            "*pycache*",
            "*backup*",
            "todo_notes",
            "templates",
            "DISCARDED", "DONE", "TODO",
            "attachments"
          },
          -- in Snacks.picker.files list, <C-s> open the file in Snacks.scratch
          actions = { },
        }
      },
      actions = m_actions,
      win = {
        input = {
          keys = m_keys,
        },
        list = {
          wo = {
            wrap = true,
            number = false,
            relativenumber = false,
          },
          keys = m_keys,
        },
      },
      layout = {
        -- options include default, ivy, dropdown, vertical, sidebar, telescope
        preset = "default",
        hidden = {"input", "preview"},
        layout = {
          min_width = 0,
          width = 0.7,
          height = 0.6,
          box = "horizontal",
          {
            box = "vertical",
            { win = "input", height = 1, border = "rounded" },
            { win = "list", border = "rounded" },
          },
          {
            win = "preview",
            title = "{preview}",
            width = 0.7, -- 70% of the picker width goes to the preview window
            border = "rounded"
          },
        },
      }
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = {
      enabled = false ,
      git =  {
        enabled = true,
        patterns = { "MiniDiffSign" },
      }
    },
    words = { enabled = false },
    styles = {
      list = {
        keys = {
          ["<C-c>"] = { "close", mode = { "i", "n" } },
        }
      },
      input = {
        -- relative = "editor",
        -- position = "center",
        row = vim.o.lines/2-10,
        keys = {
          ["<C-c>"] = { "close", mode = { "i", "n" } },
        }
      },
    },

    dashboard = {
      preset = {
        header = [[
          Meowwww
           /\_/\
          ( o.o )
           > ^ <
          __J"L__
          ]],
        keys = {
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒅 ", key = "S", desc = "Session Select", action = ":lua require('mini.sessions').select()" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        }
      },
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = 1, limit= 10},
        -- { icon = " ", title = "Projects", section = "projects", indent = 3, padding = 1 },
        { section = "startup" },
      },
    }
  },
  keys = {
    {
      "z=",
      function()
        if vim.v.count == 0 then
          Snacks.picker.spelling()
        else
          vim.cmd("normal! " .. vim.v.count .. " z=")
        end
      end,
      desc = "Spelling Suggestions",
    },
    { "<C-S-l>", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<C-Tab>", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<C-S-Tab>", "<cmd>bprevious<cr>", desc = "previous buffer" },
    { "<leader>f:", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- { "<C-n>", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>sh",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>.",
      function()
        Snacks.explorer({
          cwd = vim.uv.cwd(),
          enter = true,
        })
      end, desc = "File Explorer" },
    -- { "<C-e>", function() Snacks.explorer.reveal() end, desc = "File Explorer Reveal" },
    { "<leader>/", function() Snacks.picker.lines({layout = {hidden = {"preview"}}}) end, desc = "Grep" },
    { "<leader>ft", m_todo_from_root, desc = "find todo from root" },
    { "<leader>fk",function() Snacks.picker.keymaps({layout = {hidden = {"preview"}}}) end,desc = "keymaps" },
    { "<leader>fo",function() Snacks.picker.recent({layout = {hidden = {"preview"}}}) end,desc = "recents" },
    { "<leader>fp",function() Snacks.picker.projects() end,desc = "projects" },
    -- this won't close any current floating windows.
    { "<leader>fs",function()  Snacks.picker.smart({layout = {hidden = {"preview"}}}) end,desc = "smart" },
    { "<leader>fd",function() Snacks.picker.diagnostics_buffer() end, desc="buffer diagnostics"},
    { "<leader>fD",function() Snacks.picker.diagnostics() end, desc="diagnostics"},
    { "<leader>fg",function() Snacks.picker.git_status() end, desc="git status" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc="resume"},
    { "<leader>h",function() Snacks.picker.help({ layout = { hidden = {"preview"} } }) end,desc = "Help Page" },
    { "<leader>H", function() vim.cmd.help(vim.bo.filetype) end, desc = "get help for current file type" },
    { "<leader>fl", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>fw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>fu", function() Snacks.picker.undo({layout = {hidden = {"input"}}}) end, desc ="Undo History"  },
    { "<leader>fM", function() Snacks.picker.marks() end, desc ="full marks"  },
    { "<leader>fm",
      function()
        Snacks.picker.marks({
          transform = function(item)
            -- Only keep marks matching a-z or A-Z
            return item.label and item.label:match("^[a-zA-Z]$") ~= nil
          end
        })
      end,
      desc ="only letter marks"
    },
    { "<leader>fz", function() Snacks.zen() end, desc ="Zen"  },
    {"<leader>fc",
      function()
        F.menu_commands({
          -- { text = "Toggle Scratch Buffer"  ,  fn = Snacks.scratch },
          { text = "Rename File", fn = Snacks.rename.rename_file },
          { text = "Quickfix List" , fn = Snacks.picker.qflist},
          { text = "Marks" , fn = Snacks.picker.marks},
          { text = "Stash", fn = Snacks.picker.git_stash },
          { text = "Branches", fn = Snacks.picker.git_branches },
          { text = "Log", fn = Snacks.picker.git_log },
          { text = "Log Line", fn = Snacks.picker.git_log_line },
          { text = "Diff (Hunks)", fn = Snacks.picker.git_diff },
          { text = "Log File", fn = Snacks.picker.git_log_file },
          { text = "Issues (open)", fn = Snacks.picker.gh_issue },
          { text = "Issues (all)", fn = function() Snacks.picker.gh_issue({ state = "all" }) end },
          { text = "Pull Requests (all)", fn = function() Snacks.picker.gh_pr({ state = "all" }) end },
          { text = "Config Files", fn = function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
          { text = "Pull Requests (open)", fn = Snacks.picker.gh_pr },
          { text = "Browse", fn = Snacks.gitbrowse  },
          { text = "Git Files", fn = Snacks.picker.git_files },
          { text = "Buffer Lines" , fn = Snacks.picker.grep},
          { text = "Visual selection or word", fn = Snacks.picker.grep_word, },
          { text = "Search History" , fn = Snacks.picker.search_history},
          { text = "Autocmds" , fn = Snacks.picker.autocmds},
          { text = "Commands" , fn = Snacks.picker.commands},
          { text = "Highlights" , fn = Snacks.picker.highlights},
          { text = "Icons" , fn = Snacks.picker.icons},
          { text = "Jumps" , fn = Snacks.picker.jumps},
          { text = "Location List" , fn = Snacks.picker.loclist},
          { text = "Man Pages" , fn = Snacks.picker.man},
          { text = "Search for Plugin Spec" , fn = Snacks.picker.lazy},
          { text = "Colorschemes" , fn = Snacks.picker.colorschemes},
          -- { text = "Select Scratch Buffer"  ,  fn = Snacks.scratch.select },
        },"Snacks menu", "^" )
      end, desc = "misc snacks commands"
    },
    -- seabch
    { "<leader>sg",
      function()
        local cwd = vim.fn.expand('%:p:h')
        Snacks.picker.grep({ cwd = cwd })
      end, desc = "Grep current file's directory" },
    { "<leader>sb", function() Snacks.picker.grep_buffers() end, desc = "Grep open buffers"},
    { F.alt_key('<%s-r>'), function() Snacks.picker.registers({ confirm = {"paste", "close"} } ) end, desc = "Registers" },
    { "<leader>mp", function()
      vim.ui.input({prompt = "Man page"}, function(word)
        if word == "" then return end
        Snacks.terminal.open("man "..word)
      end)
    end, desc = "man page" },

    -- LSP
    { "K", function() vim.lsp.buf.hover()  end, nowait = true, desc = "LSP Hover Doc" },
    { "grd", function() Snacks.picker.lsp_definitions() end, desc = "LSP Goto Definition" },
    { "grD", function() Snacks.picker.lsp_declarations() end, desc = "LSP Goto Declaration" },
    { "grr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "LSP References" },
    { "gri", function() Snacks.picker.lsp_implementations() end, desc = "LSP Goto Implementation" },
    { "grt", function() Snacks.picker.lsp_type_definitions() end, desc = "LSP Goto T[y]pe Definition" },
    { "<leader>gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
    { "<leader>gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
    -- { alt_key("<C-w>", 2), function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>lg", function() Snacks.lazygit({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "lazy git log" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    -- { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    -- { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    { "<leader>`",  F.generate_bookmarks_picker, desc = "Open Link Picker" }
  },
  init = function()
    -- 6. Create a user command or keymap to run it
    -- vim.api.nvim_create_user_command("PickLink", open_markdown_links_picker, {desc="opening a snack picker for bookmark"})

    -- prevent snacks from create history
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("no_picker_hist", { clear = true }),
      callback = function()
        require("snacks.picker.util.history") -- Preload file
        vim.api.nvim_clear_autocmds({ group = "snacks_history" })
      end,
    })
  end,
}

if m_snacks.keys then
  vim.iter(m_snacks.keys)
    :each(function(key) key.desc = key.desc and "[hp]"..key.desc or "[hp][Snacks no desc]" end)
end

return m_snacks
