return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    -- Initialize mini.ai

    local ai = require('mini.ai')
    require('mini.ai').setup({
      n_lines = 500, -- Number of lines to search for textobjects
      custom_textobjects = {
        -- Function definition
        f = ai.gen_spec.treesitter({
          a = '@function.outer',
          i = '@function.inner',
        }),

        F = ai.gen_spec.treesitter({
          a = '@call.outer',
          i = '@call.inner'
        }),

        -- Class/Struct definition
        c = ai.gen_spec.treesitter({
          a = '@class.outer',
          i = '@class.inner',
        }),

        -- Code block, loop, or conditional statement
        o = ai.gen_spec.treesitter({
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        }),

        -- Function/Method call
        C = ai.gen_spec.treesitter({
          a = '@call.outer',
          i = '@call.inner',
        }),

        -- Function parameters / arguments
        -- Note: 'a' overrides mini.ai's builtin argument finder with Tree-sitter's
        a = ai.gen_spec.treesitter({
          a = '@parameter.outer',
          i = '@parameter.inner',
        }),
      },
    })

    require('mini.surround').setup({
      mappings = {
        add = 'Sa',
        delete = 'Sd',
        find = 'Sf',
        find_left = 'SF',
        highlight = 'Sh',
        replace = 'Sr',
        update_n_lines = 'Sn',
      },
    })

    -- require('mini.align').setup()

    require('mini.pairs').setup()
    require('mini.bracketed').setup()

    -- Initialize mini.diff
    require('mini.diff').setup()

    require('mini.files').setup()
    -- Open mini.files at the current working directory (CWD)
    vim.keymap.set('n', '<C-e>', function() MiniFiles.open() end, { desc = 'Open mini.files (Root)' })

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
      mappings = {
        -- Expand snippet at cursor position. Created globally in Insert mode.
        expand = '<C-.>',
        jump_next = '<C-n>',
        jump_prev = '<C-p>',
        stop = '<C-c>',
      },
    })

    require("mini.sessions").setup()
    vim.keymap.set('n', "<leader>ss", function() MiniSessions.select() end, {desc = "select and load sessino"})
    vim.keymap.set('n', "<leader>sw", function() MiniSessions.write() end, {desc = "write to session"})
    vim.keymap.set('n', "<leader>s?", function() vim.notify("Current Session:" .. vim.fs.basename(vim.v.this_session)) end, {desc = "Current session"})
    vim.keymap.set('n', "<leader>sr", function()
      MiniFiles.open(vim.fn.stdpath('data') .. '/session/')
    end, {desc = "Current session"})
    vim.keymap.set("n", "<leader>sN", function()
      vim.ui.input({ prompt = "New session name:" }, function(session_name)
        if session_name ~= "" then
          MiniSessions.write(session_name)
          require("snacks").bufdelete.all()
        end
      end)
    end, { desc = "new session"})

  end,
}
