return {
  {
    'echasnovski/mini.ai',
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", },
    version = false,
    lazy = false,
    config = function()
      local ai = require('mini.ai')
      ai.setup({
        n_lines = 500, -- Extend search scope for larger textobjects
        custom_textobjects = {
          -- Function definitions
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
          c = ai.gen_spec.treesitter({
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
        signs = { add = '+', change = '=', delete = '-' },
      },
    }
    ) end
  },
  {
    'echasnovski/mini.files',
    config = function() require("mini.files").setup({
      windows = {
        preview=true,
        width_preview =  80, -- adjusts dynamically or set to a fixed integer like 40
      }
    }) end
  },
  {
    'echasnovski/mini.completion',
    config = function()
      require("mini.completion").setup({
        lsp_completion = { auto_setup = true, source_func = 'omnifunc' },
        delay = { completion = 200, info = 200, signature = 200 },
    }) end
  },
  {
    'echasnovski/mini.snippets',
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local m_snippets =  require("mini.snippets")

      m_snippets.setup({
        -- Integrates seamlessly with mini.completion's fallback logic
        snippets = {
          m_snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),
          m_snippets.gen_loader.from_lang({lang_patterns = {
            markdown_inline = { 'markdown.json' },
          }}),
        },

        mappings = {
          -- Expand snippet at cursor position. Created globally in Insert mode.
          expand = '<C-.>',
          -- Interact with default `expand.insert` session.
          -- Created for the duration of active session(s)
          jump_next = '<C-n>',
          jump_prev = '<C-p>',
          stop = '<C-c>',
        },
      })

      -- must be after setup to add snipets to mini.completions
      require("mini.snippets").start_lsp_server()
    end
  },
  {
    'echasnovski/mini.sessions',
    config = function() require("mini.sessions").setup({
      directory = vim.fn.stdpath('config') .. '/sessions/'
    }) end,
    keys = {
      {'<C-e>', function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, desc = 'Open mini.files' },
      {'<leader>ss', function() MiniSessions.select() end, desc = 'Save current session'},
      {'<leader>sw', function() MiniSessions.write() end,  desc = 'Save current session' },
      {'<leader>s?', function() vim.notify("Current session:" .. vim.fs.basename( vim.v.this_session )) end,  desc = 'Show current session' },
      {'<leader>se', function() MiniFiles.open(vim.fn.stdpath('config') .. '/sessions/') end, { desc = 'Open mini.files Workspace' } },
      {'<leader>sD', function() MiniSessions.select('delete') end, { desc = 'Delete mini.sessions Workspace' } },
      {'<leader>sN', function()
        vim.ui.input({ prompt = 'Session Name: ' }, function(name)
          if name ~= '' then
            require('snacks').bufdelete.all()
            MiniSessions.write(name)
          end
        end)
      end, desc = 'Save named session'},
      {'<leader>sv',
        function()
          local session_name = vim.fs.basename( vim.v.this_session )
          if session_name ~= "" then
            local file_path = vim.fn.expand(vim.g.m_notes_path .. '/sessions/'..session_name .. ".md")
            Snacks.scratch({
              file = file_path,
              enter = true,
              name = "Session notes",
            })
          else
            vim.notify("Not in a session", vim.log.levels.ERROR)
          end
        end, { desc = 'Open a floating window to edit notes' } },

    },
  },
  {
    'echasnovski/mini.trailspace',
    config = function()
      -- don't call setup because don't want highlight everything
      vim.api.nvim_create_autocmd('BufWritePre', {
        desc = 'Removes trailing whitespace on save',
        callback = function()
          local ts = require("mini.trailspace")
          ts.trim()
          ts.trim_last_lines()
        end,
      })
    end,
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
  -- {
  --   'echasnovski/mini.statusline',
  --   config = function()
  --     require('mini.statusline').setup({
  --       content = {
  --         active = function()
  --           -- local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  --           local git           = MiniStatusline.section_git({ trunc_width = 40 })
  --           local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
  --           local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
  --           -- local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  --           local location = '(%l,%c)'
  --           local session = ''
  --           if vim.v.this_session ~= "" then
  --             session       =   vim.fs.basename( vim.v.this_session )
  --           end
  --
  --           return MiniStatusline.combine_groups({
  --             -- { hl = mode_hl,                  strings = { string.sub(mode, 1, 1) } },
  --             '%<', -- Mark general truncate point
  --             { hl = 'MiniStatuslineFilename', strings = { "%t" .. "%m%r",location, } },
  --             '%=', -- End left alignment
  --             { hl = 'MiniStatuslineGit', strings = { git} },
  --             { hl = 'MiniStatuslineFileinfo', strings = {lsp, diagnostics, '|' .. session  } },
  --           })
  --         end
  --       }
  --     })
  --   end
  -- },
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
