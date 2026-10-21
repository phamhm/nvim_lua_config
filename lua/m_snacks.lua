local utils = require("utils.functions")
local move_line = utils.move_line_to_file
local move_lines_select_file = utils.move_lines_select_file
local menu_commands = utils.menu_commands
local open_markdown_links_picker = utils.open_markdown_links_picker
local alt_key = utils.format_os_altkey

-- disable autocompletion in the windows. will work on vim.ui.open
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"snacks_picker", "snacks_picker_input", "snacks_input"}, -- "snacks_input""snacks_picker_input",
  callback = function()
    vim.b.minicompletion_disable = true
  end,
})

local md_scratch_ops = function(md_name)
  local keys = {
    ["archive"] = {
      "aa", function() move_line(vim.g.m_notes_path .. "/archive/archive_ideas.md") end,
      desc = "Archive idea",
      mode = {"n", },
    },
    ["select"] = {
      "ss", function() move_lines_select_file() end,
      desc = "Refile select file",
      mode = {"n", "v"},
    },
  }

  if md_name ~= "TODO.md" then
    keys["todo"] = {
      "tt", function() move_line(vim.g.m_notes_path .. "/TODO.md") end,
      desc = "Refile TODO",
      mode = {"n", },
    }
  end

  return {
    file = vim.fn.expand(vim.g.m_notes_path .. "/" .. md_name),
    enter = true,
    name = md_name,
    ft = "markdown",
    win_by_ft = {
      markdown = {
        keys = keys
      },
    }
  }
end

local m_snacks = {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    scratch = {
      root = "/tmp", -- os will clear it.
      win = {
        width = 0.7,
        height = 0.8,
        border = "rounded",
        wo = {
          wrap = true,
        }
      },
    },
    explorer = { enabled = false },
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
          term_normal = { "<C-q>", "<cmd>stopinsert<CR>", mode = "t", desc = "Escape to normal mode" },
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
        explorer = {
          auto_close = false,
          layout = {
            layout = {
              border="none",
              position="left",
              width=0.15
            }
          }
        },
        files = {
          exclude = {
            ".git",
            "node_modules",
            ".env",
            "target",
            "build",
            "archive",
            ".*env*",
            "*env*",
            "*pycache*",
            "*backup*",
          }
        }
      },
      win = {
        input = {
          keys = {
            ["<C-t>"] = { "toggle_preview", mode = { "i", "n" } },
          }
        },
        list = {
          keys = {
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
        keys = {
          ["<C-c>"] = { "close", mode = { "i", "n" } },
        },
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
    -- { "<C-M-e>", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep" },
    { "<leader>ff",function() Snacks.picker.files() end,desc = "Files" },
    { "<leader>fk",function() Snacks.picker.keymaps() end,desc = "keymaps" },
    { "<leader>fo",function() Snacks.picker.recent() end,desc = "recents" },
    -- this won't close any current floating windows.
    { "<leader>ww",
      function()
        vim.cmd("fclose")

        Snacks.picker.files({
          title = "Notes files",
          exclude = {"backups", "sessions", "assets", "archive", },
          cwd = vim.fn.expand(vim.g.m_notes_path),
        })
      end,desc = "Help Page" },
    { "<leader>fs",function()  Snacks.picker.smart() end,desc = "Help Page" },
    { "<leader>fd",function() Snacks.picker.diagnostics_buffer() end, desc="diagnostics"},
    { "<leader>fD",function() Snacks.picker.diagnostics() end, desc="diagnostics"},
    { "<leader>fr", function() Snacks.picker.resume() end, desc="resume"},
    { "<leader>h",function() Snacks.picker.help() end,desc = "Help Page" },
    { "<leader>H", function() vim.cmd.help(vim.bo.filetype) end, desc = "get help for current file type" },
    {"<leader>mc",
      function()
        menu_commands({
          { text = "Branches", fn = function() Snacks.picker.git_branches() end },
          { text = "Log", fn = function() Snacks.picker.git_log() end },
          { text = "Log Line", fn = function() Snacks.picker.git_log_line() end },
          { text = "Status", fn = function() Snacks.picker.git_status() end },
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
          { text = "Projects", fn = function() Snacks.picker.projects() end },
          { text = "Rename File", fn = function() Snacks.rename.rename_file() end },
          { text = "Buffer Lines" , fn = function() Snacks.picker.grep() end},
          { text = "Grep Open Buffers" , fn = function() Snacks.picker.grep_buffers() end},
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
    -- search
    { "<leader>sg", function() Snacks.picker.grep({ cwd = vim.fn.getcwd()}) end, desc = "Grep current file's directory" },
    -- search
    -- { '<C-r>', function() Snacks.picker.registers({ confirm = {"paste", "close"} }) end, desc = "Registers", mode='i' },
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
    { "gro", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "grs", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader><leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader><leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    {
      "<C-`>", function()
        Snacks.scratch(md_scratch_ops("working_notes.md"))
      end,
      desc="snack scrach reminder notes"
    },
    {
      alt_key("<C-%s-`>"), function()
        Snacks.scratch(md_scratch_ops("TODO.md"))
      end,
      desc="snack scrach todo notes"
    },

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
    { "<leader>`", function() open_markdown_links_picker() end, desc = "Open Link Picker" }
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
    utils.save_keys(key)
  end
end

return m_snacks
