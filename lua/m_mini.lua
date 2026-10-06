return {
  {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      -- Initialize mini.ai
      require('mini.ai').setup()

      require('mini.surround').setup(
        {
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

      -- Initialize mini.diff
      require('mini.diff').setup()

      require('mini.files').setup()
      -- Open mini.files at the current working directory (CWD)
      vim.keymap.set('n', '<C-e>', function()
        require('mini.files').open()
      end, { desc = 'Open mini.files (Root)' })

      require('mini.statusline').setup({
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git           = MiniStatusline.section_git({ trunc_width = 40 })
            local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
            local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
            local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })

            return MiniStatusline.combine_groups({
              { hl = mode_hl,                  strings = { string.sub(mode, 1, 1) } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { "%{pathshorten(fnamemodify(expand('%:p'), ':~'))}" .. "%m%r" } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { git, lsp, diagnostics," ", fileinfo } },
            })
          end
        }
      })

      -- 1. Configure mini.completion (Asynchronous completion and signature help)
      require('mini.completion').setup({
        lsp_completion = { auto_setup = true, },
        delay = { completion = 500, info = 500, signature = 300 }
      })

      -- 2. Configure mini.snippets (Handles your snippets cleanly)
      local gen_loader = require('mini.snippets').gen_loader
      require('mini.snippets').setup({
        -- Integrates seamlessly with mini.completion's fallback logic
        snippets = {
          gen_loader.from_file('~/.config/nvim/snippets/global.json'),
          gen_loader.from_lang(),
        },
      })
    end,
  },
}
