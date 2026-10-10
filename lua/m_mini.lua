return {
  'echasnovski/mini.nvim',
  version = false,
  lazy = false,
  keys = {
    {'<C-e>', function() MiniFiles.open() end, desc = 'Open mini.files' },
    {'<leader>ss', function() MiniSessions.select() end, desc = 'Save current session'},
    {'<leader>sw', function() MiniSessions.write() end,  desc = 'Save current session' },
    {'<leader>s?', function() vim.notify("Current session:" .. vim.fs.basename( vim.v.this_session )) end,  desc = 'Show current session' },
    {'<leader>se', function() MiniFiles.open(vim.fn.stdpath('data') .. '/session/') end, { desc = 'Open mini.files Workspace' } },
    {'<leader>sN', function()
      vim.ui.input({ prompt = 'Session Name: ' }, function(name)
        if name ~= '' then
          MiniSessions.write(name)
          require('snacks').bufdelete.all()
        end
      end)
    end, desc = 'Save named session'}
  },
  config = function()
    -- Initialize mini.ai
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
          a = '@class.outer',
          i = '@class.inner',
        }),

        -- function/method call
        C = ai.gen_spec.treesitter({
          a = '@call.outer',
          i = '@call.inner'
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

    require('mini.surround').setup(
      {
        n_lines = 500, -- Extend search scope for larger textobjects
        search_method = "cover_or_next",
        mappings = {
          add = 'Sa', -- Add surrounding in Normal and Visual modes
          delete = 'Sd', -- Delete surrounding
          find = 'Sf', -- Find surrounding (to the right)
          find_left = 'SF', -- Find surrounding (to the left)
          highlight = 'Sh', -- Highlight surrounding
          replace = 'Sr', -- Replace surrounding
        }
      }
    )

    require('mini.align').setup()

    require('mini.pairs').setup()
    require('mini.bracketed').setup()

    require('mini.diff').setup()

    require('mini.files').setup()
    local mfiles = require('mini.files')

    require('mini.statusline').setup({
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          local git           = MiniStatusline.section_git({ trunc_width = 40 })
          local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
          local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
          local session       = vim.fs.basename( vim.v.this_session )

          return MiniStatusline.combine_groups({
            { hl = mode_hl,                  strings = { string.sub(mode, 1, 1) } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { "%{pathshorten(fnamemodify(expand('%:p'), ':~'))}" .. "%m%r" } },
            '%=', -- End left alignment
            { hl = 'MiniStatuslineFileinfo', strings = { git, lsp, diagnostics, "|", fileinfo, 'S:'..session  } },
          })
        end
      }
    })

    -- 1. Configure mini.completion (Asynchronous completion and signature help)
    require('mini.completion').setup({
      lsp_completion = { auto_setup = true, source_func = 'omnifunc' },
      delay = { completion = 300, info = 300, signature = 100 }
    })

    -- 2. Configure mini.snippets (Handles your snippets cleanly)
    local gen_loader = require('mini.snippets').gen_loader
    require('mini.snippets').setup({
      -- Integrates seamlessly with mini.completion's fallback logic
      snippets = {
        gen_loader.from_file('~/.config/nvim/snippets/global.json'),
        gen_loader.from_lang(),
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

    require('mini.sessions').setup()
    -- require('mini.operators').setup()


    vim.api.nvim_create_autocmd('BufWritePre', {
      desc = 'Removes trailing whitespace on save',
      callback = function()
        require('mini.trailspace').trim()
        require('mini.trailspace').trim_last_lines()
      end,
    })
  end,
}
