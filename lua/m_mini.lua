local F = require("utils.functions")

local selected_mini_paths = {}

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
          width_preview =  80, -- adjusts dynamically or set to a fixed integer like 40
        },
        content = {
          prefix = function(fs_entry)
            local path = fs_entry.path
            if vim.list_contains(selected_mini_paths, path) then
              return " ", ""
            else
              return MiniFiles.default_prefix(fs_entry)
            end
          end
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

          map_buffer("<tab>",
            function()
              F._inspect(MiniFiles)
              local path = MiniFiles.get_fs_entry().path
              if not vim.list_contains(selected_mini_paths, path) then
                table.insert(selected_mini_paths, path)
              else
                selected_mini_paths = vim.iter(selected_mini_paths):filter(function(i) return i ~= path end):totable()
              end
              MiniFiles.synchronize()
            end,
            "add files to list")

          map_buffer("Z",
            function()
              if #selected_mini_paths == 0 then
                selected_mini_paths = {MiniFiles.get_fs_entry().path}
              end

              local msg = { "CONFIRM FILES TO ZIP" }
              vim.list_extend(msg, selected_mini_paths)
              table.insert(msg, " ")
              msg = table.concat(msg, "\n")
              local confirm_res = vim.fn.confirm(msg, '&Yes\n&No\n&Cancel', 1, 'Question')
              if confirm_res == 1 then
                local tar_name = os.date("%Y%m%d_%H%M%S")
                F.tar_files(tar_name, selected_mini_paths)
              end

              selected_mini_paths = {}
              MiniFiles.synchronize()
            end,
            "add files to list")
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        group = minifiles_group,
        pattern = "MiniFilesExplorerClose",
        callback = function()
          F._inspect("Clear out selected mini files")
          selected_mini_paths = {}
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
      {'<C-e>', function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, desc = 'Open mini.files' },
      {'<leader>ss',
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

                    local session_path = nil
                    for line in io.lines(session_note) do
                      if vim.startswith(line, "session_path:") then
                        local _, path = unpack(vim.split(line, ":"))
                        if vim.trim(path) ~= "" then
                          session_path = path
                        end
                        break
                      end
                    end
                    if session_path and session_path ~= "" then
                      vim.cmd.edit(session_path)
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
