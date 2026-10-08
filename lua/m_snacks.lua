  return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    indent = {
        enabled = true,
        indent = { only_scope = true },
        chunk = { enabled = true },
        animate = { enabled = false}
    },
    input = { enabled = true ,
      win = {
        relative = "editor",
        row = vim.o.lines /3,
        -- col = 0
      }
    },
    terminal = {
      win = {
        title = "terminal",
        title_post = "left",
        border = "rounded",
        position = "float"
      }
    },
    notifier = {
      enabled = true,
      timeout = 5000,
    },
    picker = {
        enabled = true ,
        ui_select = true,
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
              "archive"
            }
          }
        },
        win = {

          preview = {
            wo = {
              number = false,          -- Disables absolute line numbers
              relativenumber = false,  -- Disables relative line numbers
            },
          },


          input = {
            keys = {
              ["<D-p>"] = { "toggle_preview", mode = { "i", "n" } },
              -- ["<C-n>"] = { "toggle_preview", mode = { "i", "n" } },
            }
          }
        },
        layout = {
          -- options include default, ivy, dropdown, vertical, sidebar, telescope
          preset = "dropdown",
          preview = false,
          layout = {
            backdrop = false,
            row = vim.o.lines - 5,
            col = 0,
            width = 0.4,
            title_pos = "left",
            min_width = 80,
            height = 0.8,
            border = "none",
            box = "vertical",
            { win = "preview", title = "{preview}", height = 0.7, border = true },
            {
              box = "vertical",
              border = true,
              title = "{title} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "none" },
              { win = "list", border = "none" },
            },
          },
          -- layout = {
          --   box = "vertical",
          --   backdrop = false,
          --   row = vim.o.lines - 5,
          --   col = 0,
          --   width = 0.7,
          --   height = 0.6,
          --   border = "rounded",
          --   title = " {title} {live} {flags}",
          --   align = "left",
          --   title_pos = "left",
          --   { win = "preview", title = "{preview}", height=0.8},
          --   {
          --     box="vertical",
          --     { win = "input", height = 1, border = "none" },
          --     { win = "list", border = "none" },
          --   }
          -- },
        }
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = {
      enabled = true ,
      git =  { enabled = true}
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
      preset={
        keys = {
          { icon = "󰬱 ", key = "w", desc = "Workspace", action = ":lua Snacks.picker.files({cwd = vim.fn.expand('~/Workspace/')})" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.smart()" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒅 ", key = "S", desc = "Session Select", action = ":lua MiniSessions.select()" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },

        header = [[boooooooooo]],
      },
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    }
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>fw", function() Snacks.explorer({ cwd = "~/Workspace/"}) end, desc = "File Explorer" },
    { "<C-D-e>", function() Snacks.explorer() end, desc = "File Explorer" },
    -- make sure that explorer isn't called because using mini.files
    { "<leader>E", false}, { "<leader>fe", false}, { "<leader>fE", false},
    -- find
    -- { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>fv", function() Snacks.picker.files({ cwd = vim.fn.expand("~/Documents/vimwiki")}) end, desc = "Find Config File" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Config File" },
    { "<leader>fs", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    { "<leader>fo", function() Snacks.picker.recent() end, desc = "Recent" },
    -- git
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
    { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
    -- gh
    { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
    { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
    { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
    { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
    -- Grep
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep" },
    { "<leader>sb", function() Snacks.picker.grep() end, desc = "Buffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>sv", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    { "<leader>sg", function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end, desc = "Grep in current file's directory" },
    -- search
    { '<C-r>', function() Snacks.picker.registers({ confirm = {"paste", "close"} }) end, desc = "Registers", mode='i' },
    { '<leader>fr', function() Snacks.picker.registers({ confirm = { "paste", "close"} }) end, desc = "Registers" },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    { "<leader>mp", function()
      vim.ui.input({prompt = "Man page"}, function(word)
        if word == "" then return end
        Snacks.terminal.open("man "..word)
      end)
    end, desc = "man page in floating windows" },
    -- LSP
    { "<leader>gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "<leader>gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "<leader>gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "<leader>gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "<leader>gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "<leader>gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
    { "<leader>gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
    -- { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    -- Other
    { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },

    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    {
      "<C-`>", function()
        Snacks.scratch({
          file = vim.fn.expand("~/Documents/vimwiki/daily_reminder.md"),
          enter = true,
        })
      end,
      desc="snack scrach reminder notes"
    },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>q",  function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<C-/>", function() Snacks.terminal.toggle() end, desc = "Toggle Terminal" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
  },
  init = function()
      vim.api.nvim_create_autocmd("FileType", {
          pattern = "help",
          callback = function(ev)
              -- Check if it's already a floating window to prevent infinite loops
              if vim.api.nvim_win_get_config(0).relative ~= "" then
                  return
              end

              local buf = ev.buf
              -- Close the default help split window right after it opens
              vim.cmd("wincmd c")

              -- Re-open the help buffer using snacks.win in a styled float
              Snacks.win({
                  buf = buf,
                  style = "vscode", -- Uses snacks.nvim's built-in help window style layout
                  border = "rounded"
              })
          end,
      })

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end

        -- Override print to use snacks for `:=` command
        if vim.fn.has("nvim-0.11") == 1 then
          vim._print = function(_, ...)
            dd(...)
          end
        else
          vim.print = _G.dd
        end
        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })


    local function open_link_picker(filepath)
      local expanded_path = vim.fn.expand(filepath)

      -- Ensure the file is readable
      if vim.fn.filereadable(expanded_path) == 0 then
        vim.notify("File not found or unreadable: " .. filepath, vim.log.levels.ERROR)
        return
      end

      local items = {}

      -- Read the file line-by-line
      for line in io.lines(expanded_path) do
        -- Lua pattern matching for: [title](link)
        local title, link = line:match("^%[(.-)%]%((.-)%)")
        if title and link then
          table.insert(items, {
            text = title, -- Field used by snacks for filtering/searching
            link = link,  -- Custom field to store the URI
          })
        end
      end

      -- Launch the Snacks Picker
      Snacks.picker({
        title = "Bookmarks",
        items = items,
        layout = { preview = false},
        format = function(item, _)
          return {
            { item.text, "SnackPickerLabel"}
          }
        end,
        confirm = function(picker, item)
          picker:close()
          if item and item.link then
            local cmd
            if item.link:match(".applescript") then
              -- Run the link as a system script/command
              cmd = {"/usr/bin/osascript", item.link}
            elseif item.link:match(".zsh") then
              -- Run the link as a system script/command
              cmd = {"/bin/zsh", item.link}
            else
              cmd = { "open", item.link} -- 'open' is a osx  command
            end
            vim.system(cmd, {detach = true}, function(err, _)
              if err and err.code ~=0 then
                vim.schedule(function()
                  vim.notify("Failed to open:" .. vim.inspect(err), vim.log.levels.ERROR)
                end)
              end
            end)

          end
        end,
      })
    end

    -- Example Keymap (Adjust the path to your actual file)
    vim.keymap.set("n", "<leader>`", function()
      open_link_picker("~/Documents/vimwiki/bookmarks.md")
    end, { desc = "Search Bookmarks File" })
  end,
}
