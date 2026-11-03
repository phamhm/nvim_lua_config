local F = require("utils.functions")
local alt_key = F.format_os_altkey

local scratch_root = "/tmp"

-- disable autocompletion in the windows. will work on vim.ui.open
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"snacks_picker", "snacks_picker_input", "snacks_input"}, -- "snacks_input""snacks_picker_input",
  callback = function()
    vim.b.minicompletion_disable = true
  end,
})

-- Picker explorer actions
local function m_tcd(picker, item)
  Snacks.picker.actions.tcd(picker, item)
  print(picker:cwd())
end

local function m_explorer_up(picker, item)
  local explorer_actions = require("snacks.explorer.actions").actions
  explorer_actions.explorer_up(picker)
  print(picker:cwd())
end

local function diff_selected(picker)
  picker:close()
  local selected = picker:selected()
  if #selected == 2 then
    vim.cmd("tabnew " .. selected[1].file)
    vim.cmd("vert diffs " .. selected[2].file)
    Snacks.notify.info("Diffing " .. selected[1].file .. " & " .. selected[2].file)
  else
    vim.notify("Need 2 files to diff. Found " .. #selected, vim.log.levels.WARN)
  end
end

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
      enabled = false
      -- root = scratch_root, -- os will clear it.
      -- win_by_ft = {
      --   markdown = {
      --     keys = {
      --       ["buffer"] = {
      --         "<CR>", -- using <CR> to prevent obsidianFollowLink in floating window
      --         function()
      --           local full_path = vim.api.nvim_buf_get_name(0)
      --           vim.cmd("fclose!")
      --           vim.cmd("botright vsplit " .. full_path)
      --         end,
      --         desc = "Splt R",
      --         mode = "n"
      --       },
      --     },
      --   },
      -- },
      -- win = {
      --   keys = {
      --     ["q"] = {
      --       -- Experience weird error where my saving didn't work, nvim
      --       -- indicated something overwote it.
      --       -- After c-x all the scratches, the sav worked again.
      --       -- there function prevent scratch from saving to the tmp dir.
      --       function()
      --         local current = vim.api.nvim_buf_get_name(0)
      --
      --         local bufnr = vim.api.nvim_get_current_buf()
      --         vim.api.nvim_buf_delete(bufnr, { force = true })
      --         if string.find(current,scratch_root,1, true) then
      --           os.remove(current)
      --           os.remove(current .. ".meta")
      --         end
      --       end, desc ="Delete", mode = {"n"}}
      --   },
      --   min_width = 0,
      --   width = 0.6,
      --   height = 0.9,
      --   border = "rounded",
      --   wo = {
      --     wrap = true,
      --     number = true,
      --     relativenumber = true,
      --     -- foldlevel = 9,
      --   }
      -- },
    },
    explorer = {enabled = true,},
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
      enabled = true ,
      hidden=true,
      sources = {
        lsp_symbols = {
          layout = {
            hidden = {"preview"},
            preset = "sidebar",
          },
        },
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
            zip_selected  = zip_selected,
            diff_selected = diff_selected,
            m_tcd         = m_tcd,
            m_explorer_up = m_explorer_up,
          },
          win = {
            list = {
              keys = {
                ["Z"] = { 'zip_selected', mode = { "n" } },
                ["D"] = { 'diff_selected', mode = { "n" } },
                ["h"] = { 'm_explorer_up', mode = { "n" } },
                ["l"] = { "m_tcd", mode = { "n" } },
              }
            }
          },
          layout = {
            hidden = {"input"},
            preset = "default",
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
            -- m_open_scratch = function(picker)
            --   local file = picker:current()._path
            --   picker:close()
            --   Snacks.scratch({
            --     file = file,
            --     name = file,
            --     enter = true,
            --   })
            -- end,
          },
          win = {
            list = {
              keys = {
                -- ["<C-s>"] = {"m_open_scratch", mode = {"n"}}
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
    { alt_key("<C-%s-e>"), function() Snacks.explorer() end, desc = "File Explorer" },
    { "<C-e>", function() Snacks.explorer.reveal() end, desc = "File Explorer Reveal" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep" },
    { "<leader>ff",function() Snacks.picker.files() end,desc = "Files" },
    { "<leader>fk",function() Snacks.picker.keymaps() end,desc = "keymaps" },
    { "<leader>fo",function() Snacks.picker.recent() end,desc = "recents" },
    { "<leader>fp",function() Snacks.picker.projects() end,desc = "projects" },
    -- this won't close any current floating windows.
    { "<leader>fs",function()  Snacks.picker.smart() end,desc = "Help Page" },
    { "<leader>fd",function() Snacks.picker.diagnostics_buffer() end, desc="buffer diagnostics"},
    { "<leader>fD",function() Snacks.picker.diagnostics() end, desc="diagnostics"},
    { "<leader>fg",function() Snacks.picker.git_status() end, desc="git status" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc="resume"},
    { "<leader>h",function() Snacks.picker.help() end,desc = "Help Page" },
    { "<leader>H", function() vim.cmd.help(vim.bo.filetype) end, desc = "get help for current file type" },
    { "<leader>fl", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>fw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>fu", function() Snacks.picker.undo() end, desc ="Undo History"  },
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
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { alt_key("<%s-w>"),
      function()
        Snacks.bufdelete()
        if vim.fn.winnr('$') > 1 then
          vim.cmd.close()
        end
      end,
      desc = "Delete Buffer"
    },
    {alt_key("<%s-t>"), vim.cmd.vnew, desc = "New Vertical Buffer" },
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "lazy git log" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
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
  vim.iter(m_snacks.keys)
    :map(function(key) return string.format("%s=Snacks %s", key[1], key.desc or "no description") end)
    :each(function(key) F.save_keys(key) end)
end

return m_snacks
