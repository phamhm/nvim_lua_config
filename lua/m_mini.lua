local F = require("utils.functions")

local m_mini = {
  {
    'echasnovski/mini.ai',
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", },
    version = false,
    lazy = false,
    keys = {
      {"<C-x><C-m>", function() F.NOTIFY(MiniAi.config.search_method) end, desc = "Show MiniAi search method"},
      {"<C-x><C-a>",
        function()
          vim.ui.select(
            {
              'nearest',
              'cover_or_next',
              'next',
              'cover',
              'cover_or_prev',
              'cover_or_nearest',
              'prev',
            },
            {propmt = "Change MiniAi search method"},
            function(search_method)
              if search_method and search_method ~= "" then
                MiniAi.config.search_method = search_method
              end
            end
          )
        end,
        desc = "change Mini Ai Config"
      },
    },
    config = function()
      local ai = require('mini.ai')

      ai.setup({
        search_method = "cover_or_next",
        mappings = {
          goto_left = '[[',
          goto_right = ']]', -- really don't like this
        },
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
          use_as_default_explorer = false
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
    end
  },
  {
    'echasnovski/mini.sessions',
    dependencies = {  'jedi-knights/yaml.nvim' },
    config = function() require("mini.sessions").setup({
      directory = vim.fn.stdpath('config') .. '/sessions/',
      autowrite = true,
      verbose = {write = true, read = true}
    }) end,
    keys = {
      {'<leader>e', function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, desc = 'Open mini.files' },
      {"<leader>3",
        function()
          local session_path = string.format("%s/sessions/",vim.g.m_notes_path)
          local session_commands = {
            {text = "select", fn = MiniSessions.select},
            {text = "save current", fn = MiniSessions.write},
            {text = "delete", fn = function() MiniSessions.select('delete', {force = true}) end},
            {text = "rename", fn = function()
              local sessions = require("mini.sessions")
              -- 1. select a session to rename
              -- 2. rename its session file.
              -- 3. rename its notes file
              vim.ui.select(vim.tbl_keys(sessions.detected), {prompt = "Select session to rename"},
                function(old_session_name)
                  local current_session = vim.fs.basename(vim.v.this_session)
                  if current_session == old_session_name then
                    F.WARN("Can't rename current session")
                    return
                  end

                  vim.ui.input({prompt = "New Session Name"},
                    function(new_session_name)

                      if not new_session_name or new_session_name == "" then
                        return
                      end

                      new_session_name = new_session_name:gsub(" ","_")

                      local old_session_path = string.format("%s/%s", MiniSessions.config.directory, old_session_name):gsub("//", "/")
                      local new_session_path = string.format("%s/%s", MiniSessions.config.directory, new_session_name):gsub("//", "/")
                      if vim.uv.fs_stat(old_session_path) then
                        vim.fn.rename(old_session_path, new_session_path)
                      else
                        F.NOTIFY("Session not found:" .. old_session_path)
                        return
                      end

                      local old_session_note_path = string.format("%s/%s.md", session_path, old_session_name):gsub("//", "/")
                      local new_session_note_path = string.format("%s/%s.md", session_path, new_session_name):gsub("//", "/")
                      if vim.uv.fs_stat(old_session_note_path) then
                        vim.fn.rename(old_session_note_path, new_session_note_path)
                      end

                    end)
                end
              )
            end},
            {text = "rebuild", fn = function()
              local sessions = require("mini.sessions")
              vim.ui.select(vim.tbl_keys(sessions.detected), {prompt = "Select session to rebuild"},
                function(session_name)
                  if session_name and session_name ~= "" then
                    require('snacks').bufdelete.all()
                    MiniSessions.write(session_name)
                    local session_note_path = string.format("%s/%s.md", session_path, session_name)
                    vim.cmd.edit(session_note_path)
                    if not vim.uv.fs_stat(session_note_path) then
                      return
                    end

                    local data, err = get_yaml(session_note_path)
                    if data then
                      if data.session_path and data.session_path ~= "" then
                        vim.cmd.edit(data.session_path)
                      end
                      if data.other_paths and #data.other_paths > 0 then
                        vim.iter(data.other_paths):each(function(path) vim.cmd.badd(path) end)
                      end
                    else
                      F.ERROR("Yaml parse error")
                    end
                  end
                end)
            end},
            {text = "new session", fn = function()
              vim.ui.input({ prompt = 'Session Name: ' }, function(new_session_name)
                if new_session_name and new_session_name ~= '' then
                  require('snacks').bufdelete.all()
                  MiniSessions.write(new_session_name)
                  local session_note = string.format("%s/%s.md", session_path, new_session_name)
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
  end, desc = 'Sessions Management'},
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
      F.map('c', '<C-j>', F.fn_feedkey("<C-n>"), { expr = true, desc = 'Next history / completion' })
      F.map('c', '<C-k>', F.fn_feedkey("<C-p>"), { expr = true, desc = 'Prev history / completion' })
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

-- {key, fn, desc, mode}
for _, minimi in ipairs(m_mini) do
  if minimi.keys then
    for _, m_mini_key in ipairs(minimi.keys) do
      m_mini_key.desc = m_mini_key.desc and "[hp]"..m_mini_key.desc or "[hp][Mini no desc]"
    end
  end
end

return m_mini
