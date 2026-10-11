local m_layout = {
  preview = false,
  layout = {
    width = 0.3,
    height = 0.5,
  }
}

local function copy_dated_lines(filepath, pattern)
  -- Expand the file path (handles ~ for home directory, etc.)
  local expanded_path = vim.fn.expand(filepath)

  -- Open the file in read mode
  local file = io.open(expanded_path, "r")
  if not file then
    vim.notify("Could not open file: " .. expanded_path, vim.log.levels.ERROR)
    return
  end

  local matched_lines = {}
  -- Lua pattern matching line start '^', literal bracket '%[',
  -- 4 digits '%d%d%d%d', dash '%-', 2 digits, dash, 2 digits, literal bracket '%]'
  -- Read file line by line
  for line in file:lines() do
    if vim.startswith(line, pattern) then
      table.insert(matched_lines, line)
    end
  end
  file:close()

  -- Check if any lines matched
  if #matched_lines == 0 then
    vim.notify("No matching lines found starting with [yyyy-mm-dd]", vim.log.levels.WARN)
    return
  end

  -- Join lines with newlines and set the '*' register (system clipboard)
  local content = table.concat(matched_lines, "\n")
  vim.fn.setreg('*', content)

  vim.notify(string.format("Copied %d lines to the * register!", #matched_lines), vim.log.levels.INFO)
end

local function commands_menu(items, title)
  Snacks.picker.pick({
    pattern="^",
    items = items,
    title = title,
    format = "text",
    layout = m_layout,
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

local function open_markdown_links_picker()
  -- 1. Define the path to your file
  local file_path = vim.fn.expand(vim.g.m_vimwiki_path .. "/bookmarks.md") -- Change this to your file path

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
    layout = m_layout,
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
          return
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
        row = vim.o.lines / 5,
        -- col = 0,
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
      hidden=true,
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
            "archive",
            ".*env*",
            "*env*",
            "*pycache*",
          }
        }
      },
      win = {
        input = {
          keys = {
            ["<M-p>"] = { "toggle_preview", mode = { "i", "n" } },
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
          { icon = "󰒅 ", key = "S", desc = "Session Select", action = ":lua MiniSessions.select()" },
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
    { "<leader>cn", function()
      local today_date = os.date('%Y-%m-%d')
      local date_pattern = "[" .. today_date .."]"
      copy_dated_lines(vim.g.m_vimwiki_path .. "/daily_reminder.md", date_pattern)
    end, {desc = 'copy dated line into @* register'} },
    { "<leader>,", function() Snacks.picker.buffers({hidden=true, nofile=true}) end, desc = "Buffers" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<C-M-e>", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Grep" },
    { "<leader>ff",function() Snacks.picker.files() end,desc = "Files" },
    { "<leader>fo",function() Snacks.picker.recent() end,desc = "recents" },

    {"<M-s>",
      function()
        commands_menu({
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
          { text = "Workspace dir" , fn = function() Snacks.explorer({ cwd = "~/Workspace" }) end},
          { text = "Config Files", fn = function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
          { text = "Vimwiki", fn = function() Snacks.picker.files({ cwd = vim.fn.expand(vim.g.m_vimwiki_path)}) end },
          { text = "Smart Files", fn = function() Snacks.picker.smart() end },
          { text = "Git Files", fn = function() Snacks.picker.git_files() end },
          { text = "Projects", fn = function() Snacks.picker.projects() end },
          { text = "Rename File", fn = function() Snacks.rename.rename_file() end },
          { text = "Buffer Lines" , fn = function() Snacks.picker.grep() end},
          { text = "Grep Open Buffers" , fn = function() Snacks.picker.grep_buffers() end},
          { text = "Visual selection or word", fn = function() Snacks.picker.grep_word() end, },
          { text = "Search History" , fn = function() Snacks.picker.search_history() end},
          { text = "Autocmds" , fn = function() Snacks.picker.autocmds() end},
          { text = "Commands" , fn = function() Snacks.picker.commands() end},
          { text = "Diagnostics" , fn = function() Snacks.picker.diagnostics() end},
          { text = "Buffer Diagnostics" , fn = function() Snacks.picker.diagnostics_buffer() end},
          { text = "Help Pages" , fn = function() Snacks.picker.help() end},
          { text = "Highlights" , fn = function() Snacks.picker.highlights() end},
          { text = "Icons" , fn = function() Snacks.picker.icons() end},
          { text = "Jumps" , fn = function() Snacks.picker.jumps() end},
          { text = "Keymaps" , fn = function() Snacks.picker.keymaps() end},
          { text = "Location List" , fn = function() Snacks.picker.loclist() end},
          { text = "Marks" , fn = function() Snacks.picker.marks() end},
          { text = "Man Pages" , fn = function() Snacks.picker.man() end},
          { text = "Search for Plugin Spec" , fn = function() Snacks.picker.lazy() end},
          { text = "Quickfix List" , fn = function() Snacks.picker.qflist() end},
          { text = "Resume" , fn = function() Snacks.picker.resume() end},
          { text = "Undo History" , fn = function() Snacks.picker.undo() end},
          { text = "Colorschemes" , fn = function() Snacks.picker.colorschemes() end},
        },"Snacks menu" )
      end
    },
    -- search
    { "<leader>sg", function() Snacks.picker.grep({ cwd = vim.fn.getcwd()}) end, desc = "Grep current file's directory" },
    -- search
    { '<C-r>', function() Snacks.picker.registers({ confirm = {"paste", "close"} }) end, desc = "Registers", mode='i' },
    { '<leader>r', function() Snacks.picker.registers({ confirm = {"paste", "close"} } ) end, desc = "Registers" },
    { "<leader>mp", function()
      vim.ui.input({prompt = "Man page"}, function(word)
        if word == "" then return end
        Snacks.terminal.open("man "..word)
      end)
    end, desc = "Colorschemes" },

    -- LSP
    { "<leader>gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "<leader>gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "<leader>gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "<leader>gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "<leader>gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "<leader>gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
    { "<leader>gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
    { "<leader>gs", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>gS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    {
      "<C-`>", function()
        Snacks.scratch({
          file = vim.fn.expand(vim.g.m_vimwiki_path .. "/daily_reminder.md"),
          enter = true,
          win = {
            title = "Daily reminder"
          }
        })
      end,
      desc="snack scrach reminder notes"
    },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>q",  function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>lg",
      function()
        local today_date = os.date('%Y-%m-%d')
        local date_pattern = "[" .. today_date .."]"
        copy_dated_lines(vim.g.m_vimwiki_path .. "/daily_reminder.md", date_pattern)
        Snacks.lazygit()
      end, desc = "Lazygit" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<C-/>",      function() Snacks.terminal.toggle() end, desc = "Toggle Terminal" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
  },
  init = function()
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "help",
    --   callback = function(ev)
    --     -- Check if it's already a floating window to prevent infinite loops
    --     if vim.api.nvim_win_get_config(0).relative ~= "" then
    --       return
    --     end
    --
    --     local buf = ev.buf
    --     -- Close the default help split window right after it opens
    --     vim.cmd("wincmd c")
    --
    --     -- Re-open the help buffer using snacks.win in a styled float
    --     Snacks.win({
    --       buf = buf,
    --       style = "vscode", -- Uses snacks.nvim's built-in help window style layout
    --       border = "rounded"
    --     })
    --   end,
    -- })

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




    -- 6. Create a user command or keymap to run it
    -- vim.api.nvim_create_user_command("PickLink", open_markdown_links_picker, {desc="opening a snack picker for bookmark"})
    vim.keymap.set("n", "<leader>`", function() open_markdown_links_picker() end, { desc = "Open Link Picker" })
  end,
}
