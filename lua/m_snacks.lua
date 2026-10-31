local F = require("utils.functions")
local alt_key = F.format_os_altkey

-- disable autocompletion in the windows. will work on vim.ui.open
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"snacks_picker", "snacks_picker_input", "snacks_input"}, -- "snacks_input""snacks_picker_input",
  callback = function()
    vim.b.minicompletion_disable = true
  end,
})

local function zip_selected(picker, item)
  local path_to_files = vim.fn.fnamemodify(item._path, ":h")

  local filenames = vim.iter(picker:selected({fallback = true}))
    :map(function(i) return vim.fn.fnamemodify(i._path, ":t") end)
    :totable()

  vim.notify("File(s) to tar:\n" .. table.concat(filenames,"\n"))

  vim.ui.input({prompt = "tar file name"},
    function(tar_name)
      local tar_filename = string.format("~/Backups/%s.tar.gz",tar_name)
      tar_filename = vim.fn.expand(tar_filename)
      local cmd = {
        "tar",
        "-cvzf",
        tar_filename
      }
      vim.list_extend(cmd, filenames)

      vim.system(cmd, { cwd = path_to_files }, function(obj)
        if obj.code == 0 then
          vim.notify("Zipped successfully!")
        else
          vim.notify("Error zipping files: " .. obj.stderr, vim.log.levels.ERROR)
        end
      end)
    end
  )

  -- Combine the 'tar -cvzf <archive> <files...>' command
end

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
    scratch = {
      root = "/tmp", -- os will clear it.
      win_by_ft = {
        markdown = {
          keys = {
            ["buffer"] = {
              "<CR>", -- using <CR> to prevent obsidianFollowLink in floating window
              function()
                local full_path = vim.api.nvim_buf_get_name(0)
                vim.cmd("fclose")
                vim.cmd("botright vsplit " .. full_path)
              end,
              desc = "Splt R",
              mode = "n"
            },
          },
        },
      },
      win = {
        min_width = 0,
        width = 0.6,
        height = 0.9,
        border = "rounded",
        wo = {
          wrap = true,
          number = false,
          relativenumber = false,
          foldlevel = 0,
        }
      },
    },
    explorer = { enabled = true },
    bigfile = { enabled = true },
    indent = {
      enabled = true,
      indent = { only_scope = true },
      chunk = { enabled = true },
      animate = { enabled = false}
    },
    input = { enabled = true  },
    terminal = {
      win = {
        title = "terminal",
        title_post = "left",
        border = "rounded",
        position = "float",
        keys = {
          -- Overrides the double-escape behavior to exit instantly
          term_normal = { "<C-/>", "<cmd>stopinsert<CR>", mode = "t", desc = "Escape to normal mode" },
        },
      }
    },
    notifier = {
      enabled = true,
      timeout = 5000,
    },
    picker = {

      enabled = true ,
      hidden=true,
      sources = {
        select = {
          -- Set the layout preset (e.g., "select", "dropdown", "ivy", "vscode", "telescope")
          layout = {
            hidden = {"preview", "input"},
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
            zip_selected = zip_selected,
          },
          win = {
            list = {
              keys = {
                ["Z"] = { 'zip_selected', mode = { "i", "n" } },
              }
            }
          },
          layout = {
            hidden = {"input"},
            layout = {
              border="none",
              position="left",
              width=0.15
            }
          }
        },
        files = {
          focus = {},
          layout = {
            hidden = {},
            layout = {
              min_width = 0,
              width = 0.9,
              height = 0.9,
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
          actions = {
            m_open_scratch = function(picker)
              local file = picker:current()._path
              picker:close()
              Snacks.scratch({
                file = file,
                name = file,
                enter = true,
              })
            end,
          },
          win = {
            list = {
              keys = {
                ["<C-s>"] = {"m_open_scratch", mode = {"n"}}
              },
            }
          }
        }
      },
      win = {
        input = {
          keys = {
            [alt_key("<%s-p>")] = { "toggle_preview", mode = { "i", "n" } },
            ["<C-c>"] = { "close", mode = { "i", "n" } },
          }
        },
        list = {
          wo = {
            wrap = true,
            number = false,
            relativenumber = false,
          },
          keys = {
            [alt_key("<%s-p>")] = { "toggle_preview", mode = { "i", "n" } },
            ["<C-c>"] = { "close", mode = { "i", "n" } },
          }
        },
      },
      layout = {
        -- options include default, ivy, dropdown, vertical, sidebar, telescope
        preset = "default",
        preview = true,
        layout = {
          -- box = "vertical",
          -- backdrop = false,
          -- row = vim.o.lines - 5,
          -- col = 0,
          -- width = 0.5,
          -- height = 0.5,
          -- border = "rounded",
          -- title = " {title} {live} {flags}",
          -- align = "left",
          -- title_pos = "left",
          -- { win = "input", height = 1, border = "none" },
          -- {
          --   box = "horizontal",
          --   { win = "list", border = "none" },
          --   { win = "preview", title = "{preview}", width = 0.6, border = "left" },
          -- },
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
          boooooo
          __J"L__
          ,-"`--...--'"-.
          /  /\       /\   \
          J  /__\  _  /__\   L
          |       / \        |
          J    _  """  _     F
          \   \\/\_/\//    /
          "-._\/\_/\/_,-"
          """""""
          ]],
        keys = {
          { icon = "󰬱 ", key = "w", desc = "Workspace", action = ":lua Snacks.picker.files({cwd = vim.fn.expand('~/Workspace/')})" },
          -- { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.smart()" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          -- { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})" },
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
    -- Top Pickers & Explorer
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<C-M-e>", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep" },
    { "<leader>ff",function() Snacks.picker.files() end,desc = "Files" },
    { "<leader>fk",function() Snacks.picker.keymaps() end,desc = "keymaps" },
    { "<leader>fo",function() Snacks.picker.recent() end,desc = "recents" },
    { "<leader>fp",function() Snacks.picker.projects() end,desc = "projects" },
    -- this won't close any current floating windows.
    { "<leader>ww",
      function()
        Snacks.picker.files({
          cwd =vim.g.m_notes_path,
          layout = {
            hidden = {"input"},
          },
          focus = "list",
        })
      end,desc = "My Notes" },
    { "<leader>fs",function()  Snacks.picker.smart() end,desc = "Help Page" },
    { "<leader>fd",function() Snacks.picker.diagnostics_buffer() end, desc="diagnostics"},
    { "<leader>fD",function() Snacks.picker.diagnostics() end, desc="diagnostics"},
    { "<leader>fg",function() Snacks.picker.git_status() end, desc="git status" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc="resume"},
    { "<leader>h",function() Snacks.picker.help() end,desc = "Help Page" },
    { "<leader>H", function() vim.cmd.help(vim.bo.filetype) end, desc = "get help for current file type" },
    { "<leader>fl", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>fw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    {"<leader>mc",
      function()
        F.menu_commands({
          { text = "Branches", fn = function() Snacks.picker.git_branches() end },
          { text = "Log", fn = function() Snacks.picker.git_log() end },
          { text = "Log Line", fn = function() Snacks.picker.git_log_line() end },
          { text = "Stash", fn = function() Snacks.picker.git_stash() end },
          { text = "Diff (Hunks)", fn = function() Snacks.picker.git_diff() end },
          { text = "Log File", fn = function() Snacks.picker.git_log_file() end },
          { text = "Issues (open)", fn = function() Snacks.picker.gh_issue() end },
          { text = "Issues (all)", fn = function() Snacks.picker.gh_issue({ state = "all" }) end },
          { text = "Pull Requests (open)", fn = function() Snacks.picker.gh_pr() end },
          { text = "Pull Requests (all)", fn = function() Snacks.picker.gh_pr({ state = "all" }) end },
          { text = "Browse", fn = function() Snacks.gitbrowse() end  },
          -- { text = "Workspace dir" , fn = function() Snacks.explorer({ cwd = "~/Workspace" }) end},
          { text = "Config Files", fn = function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
          { text = "Git Files", fn = function() Snacks.picker.git_files() end },
          { text = "Rename File", fn = function() Snacks.rename.rename_file() end },
          { text = "Buffer Lines" , fn = function() Snacks.picker.grep() end},
          { text = "Visual selection or word", fn = function() Snacks.picker.grep_word() end, },
          { text = "Search History" , fn = function() Snacks.picker.search_history() end},
          { text = "Autocmds" , fn = function() Snacks.picker.autocmds() end},
          { text = "Commands" , fn = function() Snacks.picker.commands() end},
          -- { text = "Help Pages" , fn = function() Snacks.picker.help() end},
          { text = "Highlights" , fn = function() Snacks.picker.highlights() end},
          { text = "Icons" , fn = function() Snacks.picker.icons() end},
          { text = "Jumps" , fn = function() Snacks.picker.jumps() end},
          { text = "Location List" , fn = function() Snacks.picker.loclist() end},
          { text = "Marks" , fn = function() Snacks.picker.marks() end},
          { text = "Man Pages" , fn = function() Snacks.picker.man() end},
          { text = "Search for Plugin Spec" , fn = function() Snacks.picker.lazy() end},
          { text = "Quickfix List" , fn = function() Snacks.picker.qflist() end},
          { text = "Undo History" , fn = function() Snacks.picker.undo() end},
          { text = "Colorschemes" , fn = function() Snacks.picker.colorschemes() end},
        },"Snacks menu" )
      end
    },
    -- seabch
    { "<leader>sg", function() Snacks.picker.grep({ cwd = vim.fn.getcwd()}) end, desc = "Grep current file's directory" },
    { "<leader>sb", function() Snacks.picker.grep_buffers() end, desc = "Grep open buffers"},
    { '<leader>r', function() Snacks.picker.registers({ confirm = {"paste", "close"} } ) end, desc = "Registers" },
    { "<leader>mp", function()
      vim.ui.input({prompt = "Man page"}, function(word)
        if word == "" then return end
        Snacks.terminal.open("man "..word)
      end)
    end, desc = "Colorschemes" },

    -- LSP
    { "K", function() vim.lsp.buf.hover({border='rounded'}) end, nowait = true, desc = "LSP Hover Doc" },
    { "grd", function() Snacks.picker.lsp_definitions() end, desc = "LSP Goto Definition" },
    { "grD", function() Snacks.picker.lsp_declarations() end, desc = "LSP Goto Declaration" },
    { "grr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "LSP References" },
    { "gri", function() Snacks.picker.lsp_implementations() end, desc = "LSP Goto Implementation" },
    { "grt", function() Snacks.picker.lsp_type_definitions() end, desc = "LSP Goto T[y]pe Definition" },
    { "<leader>gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
    { "<leader>gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
    { "<leader><leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader><leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    {
      "<leader>q",
      function()
        Snacks.bufdelete()
        if vim.fn.winnr('$') > 1 then
          vim.cmd('close')
        end
      end,
      desc = "Delete Buffer"
    },
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "lazy git log" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<C-/>",      function() Snacks.terminal.toggle() end, desc = "Toggle Terminal" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
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
  for _, val in ipairs(m_snacks.keys) do
    local key = val[1] ..":".. "Snacks "..(val.desc or "no description")
    F.save_keys(key)
  end
end

return m_snacks
