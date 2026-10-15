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

          -- Code blocks, loops, or conditionals
          o = ai.gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }),

          -- Function/Method parameters or arguments
          a = ai.gen_spec.treesitter({
            a = '@parameter.outer',
            i = '@parameter.inner',
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
  --   'echasnovski/mini.pairs',
  --   config = function() require("mini.pairs").setup() end
  -- },
  {
    'echasnovski/mini.bracketed',
    config = function() require("mini.bracketed").setup() end
  },
  {
    'nvim-mini/mini.diff',
    lazy=false,
    config =  function() require("mini.diff").setup({
      view = {
        -- Signs used for hunks with 'sign' view
        signs = { add = '+', change = '|', delete = '--' },
      },
    }
    ) end
  },
  {
    'echasnovski/mini.bracketed',
    config = function() require("mini.bracketed").setup() end
  },
  {
    'echasnovski/mini.files',
    config = function() require("mini.files").setup({
      mappings = {
        -- close = '<C-c>',
      }
    }) end
  },
  {
    'echasnovski/mini.completion',
    config = function() require("mini.completion").setup({
      lsp_completion = { auto_setup = true, source_func = 'omnifunc' },
      delay = { completion = 300, info = 300, signature = 100 }
    }) end
  },
  {
    'echasnovski/mini.snippets',
    config = function() require("mini.snippets").setup({
      -- Integrates seamlessly with mini.completion's fallback logic
      snippets = {
        require("mini.snippets").gen_loader.from_file('~/.config/nvim/snippets/global.json'),
        require("mini.snippets").gen_loader.from_lang(),
      },
      { prefix='cdate', body='$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE' },

      expand = {
        -- Teach mini.snippets to look for markdown snippets when filetype is vimwiki
        ext_match = function(ctx)
          if vim.bo.filetype == 'vimwiki' then
            return { 'vimwiki', 'markdown' , 'markdown_inline'}
          end
          return { vim.bo.filetype }
        end
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
    }) end
  },
  {
    'echasnovski/mini.sessions',
    config = function() require("mini.sessions").setup({
      directory = vim.fn.stdpath('config') .. '/sessions/'
    }) end,
    keys = {
      {'<C-e>', function() MiniFiles.open() end, desc = 'Open mini.files' },
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
          local session = vim.fs.basename( vim.v.this_session )
          if session ~= "" then
            vim.cmd("edit "..vim.g.m_vimwiki_path .. '/sessions/'..session .. ".md")
          else
            vim.notify("Not in a session", vim.log.levels.ERROR)
          end
        end, { desc = 'Delete mini.sessions Workspace' } },

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
  {
    'echasnovski/mini.statusline',
    config = function()
      vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = '#aaf0c9', bg = '#222222' })
      vim.api.nvim_set_hl(0, 'MiniStatuslineGit', { fg = '#ffffff', bg = '#222222' })

      require('mini.statusline').setup({
        content = {
          active = function()
            -- local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git           = MiniStatusline.section_git({ trunc_width = 40 })
            local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
            local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
            -- local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location = '(%l:%c)'
            local session = ''
            if vim.v.this_session ~= "" then
              session       =   vim.fs.basename( vim.v.this_session )
            end

            return MiniStatusline.combine_groups({
              -- { hl = mode_hl,                  strings = { string.sub(mode, 1, 1) } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { "%t" .. "%m%r", location} },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineGit', strings = { git} },
              { hl = 'MiniStatuslineFileinfo', strings = {lsp, diagnostics, '|' .. session  } },
            })
          end
        }
      })
    end
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
