local F = require("utils.functions")

local s = {
  SELECTED_MINI_PATHS = {},
}

s.toggle = function(path)
  if vim.list_contains(s.SELECTED_MINI_PATHS, path) then
    s.SELECTED_MINI_PATHS = vim.iter(s.SELECTED_MINI_PATHS)
      :filter(function(i) return i ~= path end)
      :totable()
  else
    table.insert(s.SELECTED_MINI_PATHS, path)
  end
end

s.prefix =  function(fs_entry)
  local path = fs_entry.path
  if vim.list_contains(s.SELECTED_MINI_PATHS, path) then
    return " ", ""
  else
    return require('mini.files').default_prefix(fs_entry)
  end
end

s.reset = function()
  s.SELECTED_MINI_PATHS = {}
end

s.get_len = function ()
  return #s.SELECTED_MINI_PATHS
end

s.get = function()
  return s.SELECTED_MINI_PATHS
end

local m_mini = {
  {
    'echasnovski/mini.ai',
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", },
    version = false,
    lazy = false,
    config = function()
      local ai = require('mini.ai')
      ai.setup({
        n_lines = 200, -- Extend search scope for larger textobjects. 50 is fine
        custom_textobjects = {
          -- Function definitions
          -- h = ai.gen_spec.treesitter({
          --   a = '@markup.heading.2.outer',
          --   i = '@markup.heading.2.inner',
          -- }),

          f = ai.gen_spec.treesitter({
            a = '@function.outer',
            i = '@function.inner',
          }),

          -- Function calls (e.g., `func(val)`)
          F = ai.gen_spec.treesitter({
            a = '@call.outer',
            i = '@call.inner',
          }),

          -- Class definitions
          ["/"] = ai.gen_spec.treesitter({
            a = '@comment.outer',
            i = '@comment.inner',
          }),

          -- Class definitions
          C = ai.gen_spec.treesitter({
            a = '@class.outer',
            i = '@class.inner',
          }),

          L = ai.gen_spec.treesitter({
            a = { '@loop.outer' },
            i = { '@loop.inner' },
          }),

          I = ai.gen_spec.treesitter({
            a = { '@conditional.outer' },
            i = { '@conditional.inner' },
          }),

          -- Code blocks, loops, or conditionals
          B = ai.gen_spec.treesitter({
            a = { '@block.outer', },
            i = { '@block.inner', },
          }),

          h = ai.gen_spec.treesitter({
            a = { '@section.outer', },
            i = { '@section.inner', },
          }),
        },
      })
    end
  },
  {
    'echasnovski/mini.align',
    config = function() require("mini.align").setup() end
  },
  -- {
  --   'echasnovski/mini.bracketed',
  --   config = function() require("mini.bracketed").setup() end
  -- },
  {
    'nvim-mini/mini.diff',
    lazy=false,
    config =  function() require("mini.diff").setup({
      view = {
        style = 'sign',
        signs = { add = '┃', change = '┃', delete = '󰗨 ' },
      },
    }
    ) end
  },
  {
    'echasnovski/mini.files',
    config = function()
      require("mini.files").setup({
        options = {
          use_as_default_explorer = true
        },
        windows = {
          preview=true,
          width_preview =  70, -- adjusts dynamically or set to a fixed integer like 40
        },
        mappings = {
          go_in = "<C-l>",
          go_in_plus = "<C-L>",
          go_out = "<C-h>",
          go_out_plus = "<C-H>",
        }
      })

      local minifiles_group = vim.api.nvim_create_augroup("MiniFilesGroup", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = minifiles_group,
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id

          -- Helper function for local mappings
          local map_buffer = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
          end

          map_buffer("<C-j>", "<Nop>", "up key")

          map_buffer("<cr>",
            function()
              if s.get_len() == 0 then
                MiniFiles.go_in()
              else
                vim.iter(s.get()):each(function(file) vim.cmd.badd(file) end)
                MiniFiles.close()
              end
            end,
            "Enter to go in")

          map_buffer("<BS>",
            function()
              MiniFiles.go_out()
            end,
            "Enter to go out")

          map_buffer("<tab>",
            function()
              local path = MiniFiles.get_fs_entry().path
              s.toggle(path)

              MiniFiles.refresh({ content = { prefix = s.prefix } })
            end,
            "add files to list")

          map_buffer("Z",
            function()
              local to_tar = s.get_len() >0 and s.get() or { MiniFiles.get_fs_entry().path }

              vim.ui.input({prompt = "New Zip File Name"},
                function(tar_name)
                  if tar_name ~= "" then
                    vim.notify("tarring into " .. tar_name)
                    F.tar_files(tar_name, to_tar)
                  else
                    vim.notify("No tar name provided", vim.log.levels.WARN)
                  end
                end)

              MiniFiles.close()
            end,
            "ZIP selected files")
        end,
      })

      -- don't need to call this becasue Buf Create will init
      vim.api.nvim_create_autocmd("User", {
        group = minifiles_group,
        pattern = {"MiniFilesExplorerClose","MiniFilesExplorerOpen" },
        callback = function()
          s.reset()
        end,
      })
    end
  },
  {
    'echasnovski/mini.sessions',
    config = function() require("mini.sessions").setup({
      directory = vim.fn.stdpath('config') .. '/sessions/',
      autowrite = true,
      verbose = {write = true, read = true}
    }) end,
    keys = {
      {'<C-e>',
        function()
          SELECTED_MINI_PATHS = {}
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
        end, desc = 'Open mini.files' },
      {F.format_os_altkey("<C-%s-`>"),
        function()
          local session_path = string.format("%s/sessions/",vim.g.m_notes_path)
          local session_commands = {
            {text = "select", fn = MiniSessions.select},
            {text = "write ", fn = MiniSessions.write},
            {text = "delete", fn = function() MiniSessions.select('delete') end},
            {text = "rebuild", fn = function()
              local sessions = require("mini.sessions")
              vim.ui.select(vim.tbl_keys(sessions.detected), {prompt = "Select session to rebuild"},
                function(session_name)
                  if session_name and session_name ~= "" then
                    require('snacks').bufdelete.all()
                    MiniSessions.write(session_name)
                    local session_note = string.format("%s/%s.md", session_path, session_name)
                    vim.cmd.edit(session_note)
                    if not vim.uv.fs_stat(session_note) then
                      return
                    end

                    local yaml_session_path = nil
                    for line in io.lines(session_note) do
                      if vim.startswith(line, "yaml_session_path:") then
                        local _, path = unpack(vim.split(line, ":"))
                        if vim.trim(path) ~= "" then
                          yaml_session_path = path
                        end
                        break
                      end
                    end
                    if yaml_session_path and yaml_session_path ~= "" then
                      vim.cmd.edit(yaml_session_path)
                    end
                  end
                end)
            end},
            {text = "new session", fn = function()
              vim.ui.input({ prompt = 'Session Name: ' }, function(session_name)
                if session_name and session_name ~= '' then
                  require('snacks').bufdelete.all()
                  MiniSessions.write(session_name)
                  local session_note = string.format("%s/%s.md", session_path, session_name)
                  local yaml = {
                    "---",
                    "session_path:",
                    "---"
                  }
                  vim.fn.writefile(yaml, session_note)
                  vim.cmd.edit(session_note)
                end
              end)
            end} ,
          }

          F.menu_commands(session_commands, "Session commands", "")
        end, desc = 'Mini Sessions Management'},
    },
  },
  {
    'echasnovski/mini.trailspace',
  },
  {
    'echasnovski/mini.splitjoin',
    config = function()
      require("mini.splitjoin").setup({
        mappings = {
          toggle = '',
          split = 'gS',
          join = 'gJ',
        },
      })
    end,
  },
  {
    'nvim-mini/mini.cmdline',
    config = function()
      require('mini.cmdline').setup({})
    end,
  },
  {
    'nvim-mini/mini-git',
    version = '*', -- Use main or stable branch
    lazy=false, -- ministatusline won't work if lazy loaded
    config = function()
      require('mini.git').setup()
    end,
    keys = {
      {"<leader>gc", function() MiniGit.show_at_cursor() end, desc = "show git at cursor"}
    }
  },
}

for _, minimi in ipairs(m_mini) do
  if minimi.keys then
    for _, val in ipairs(minimi.keys) do
      local key = val[1] .."=".. "Mini "..(val.desc or "no description")
      F.save_keys(key)
    end
  end
end


-- use Mini.Files locate the file under cursor.
-- map('n', '<leader>gf', function()
--   -- Get the file path under the cursor using Neovim's built-in <cfile>
--   local target = vim.fn.expand('<cfile>')
--
--   -- Fallback to the current buffer's directory if <cfile> is empty
--   if target == "" then
--     MiniFiles.open(vim.api.nvim_buf_get_name(0))
--     return
--   end
--
--   -- Resolve full path relative to current working directory if it's not absolute
--   local full_path = vim.fn.fnamemodify(target, ':p')
--
--   -- Check if the target is a directory or a file
--   if vim.fn.isdirectory(full_path) == 1 then
--     MiniFiles.open(full_path)
--   else
--     -- If it's a file, get its parent directory
--     local dir = vim.fn.fnamemodify(full_path, ':h')
--     MiniFiles.open(dir)
--   end
-- end, { desc = "Open MiniFiles in directory of file under cursor" })



return m_mini
