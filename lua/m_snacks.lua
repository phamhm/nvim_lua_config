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
    input = {
      enabled = true ,
      win = {
        relative = "editor",
        row = vim.o.lines,
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
          input = {
            keys = {
              ["<C-p>"] = { "toggle_preview", mode = { "i", "n" } },
              ["<C-n>"] = { "toggle_preview", mode = { "i", "n" } },
            }
          }
        },
        layout = {
          -- options include default, ivy, dropdown, vertical, sidebar, telescope
          preset = "ivy",
          preview = false,
          layout = {
            box = "vertical",
            backdrop = false,
            row = vim.o.lines - 5,
            col = 0,
            width = 0.5,
            height = 0.5,
            border = "rounded",
            title = " {title} {live} {flags}",
            align = "left",
            title_pos = "left",
            { win = "input", height = 1, border = "none" },
            {
              box = "horizontal",
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", width = 0.6, border = "left" },
            },
          },
        }
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = {
      enabled = true ,
      git =  { enabled = false}
    },
    words = { enabled = true },
    styles = {
      input = {
          keys = {
              ["<C-c>"] = { "close", mode = { "i", "n" } },
          },
      },
    },

    dashboard = {
      preset = {
        keys = {
          { icon = "W ", key = "w", desc = "Workspace", action = ":lua Snacks.picker.files({cwd = vim.fn.expand('~/Workspace/')})" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.smart()" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        }
      },
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 3, padding = 1 },
        { section = "startup" },
      },
    }
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<C-e>", function() Snacks.explorer() end, desc = "File Explorer" },
    -- make sure that explorer isn't called because using mini.files
    { "<leader>e", false}, { "<leader>E", false}, { "<leader>fe", false}, { "<leader>fE", false},
    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>fv", function() Snacks.picker.files({ cwd = vim.fn.expand("~/Documents/vimwiki")}) end, desc = "Find Config File" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Config File" },
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
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    -- search
    { '<C-r>', function()
          -- Call snacks picker for registers and handle the selection confirmation
          Snacks.picker.registers({
            confirm = function(picker, item)
              picker:close()

              -- The selected item contains the register name/char
              if item and item.reg then
                -- Feed keys: <C-o> runs one normal command then returns to insert mode,
                -- followed by `"regp` to paste the selected register content.
                local keys = string.format("\"%sp==", item.reg)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
              end
            end,
          })
        end, desc = "Registers", mode='i' },
    { '<leader>fr', function() Snacks.picker.registers() end, desc = "Registers" },
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
    end, desc = "Colorschemes" },

    -- LSP
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
    { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    -- Other
    { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },

    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    {
      "<leader>`", function()
        Snacks.scratch({
          file = vim.fn.expand("~/Documents/vimwiki/daily_reminder.md"),
          -- optionally set enter = true to focus the window immediately
          enter = true,
        })
      end,
      desc="snack scrach reminder notes"
    },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<C-/>",      function() Snacks.terminal.toggle() end, desc = "Toggle Terminal" },
    { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
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


    local function open_markdown_links_picker()
      -- 1. Define the path to your file
      local file_path = vim.fn.expand("~/Documents/vimwiki/bookmarks.md") -- Change this to your file path

      -- 2. Read lines from the file
      local lines = vim.fn.readfile(file_path)
      local items = {}

      -- 3. Parse each line for the [title](link) format
      for _, line in ipairs(lines) do
        local title, link = line:match("%[(.-)%]%((.-)%)")
        if title and link then
          table.insert(items, {
            text = title,    -- What shows up and is searchable in the picker
            link = link,     -- Store the URL to use on confirmation
          })
        end
      end

      -- 4. Open the Snacks picker if we found any links
      if #items == 0 then
        vim.notify("No valid Markdown links found in the file", vim.log.levels.WARN)
        return
      end

      Snacks.picker.pick({
        source = "markdown_links",
        items = items,
        title = "Select Link to Open",
        format = "text", -- Display only the title in the list
        layout = {
          preview = false,
          layout = {
            width = 0.2,
            height = 0.3,
          }
        },
        confirm = function(picker, item)
          picker:close()
          if item and item.link then
            -- 5. Open the link using your system's default handler
            local cmd
            if item.link:match("http://") or item.link:match("https://") then
              cmd = {"google-chrome", item.link}
            elseif  item.link:match(".zsh") then
              cmd = {"$(which zsh)", item.link}
            elseif item.link == "edit" then
              vim.cmd.edit(file_path)
              return
            else
              vim.notify("Unexpected format " .. item.text .. ":" .. item.link, vim.log.levels.ERROR)
            end
            vim.system(cmd, { detach = true}, function(err, _)
              if err and err.code ~= 0 then
                vim.schedule(function()
                  vim.notify("Failed to run:" .. vim.inspect(err), vim.log.levels.ERROR)
                end)
              end
            end)
          end
        end,
      })
    end

    -- 6. Create a user command or keymap to run it
    -- vim.api.nvim_create_user_command("PickLink", open_markdown_links_picker, {desc="opening a snack picker for bookmark"})
    vim.keymap.set("n", "<leader>bm", function() open_markdown_links_picker() end, { desc = "Open Link Picker" })
  end,
}
