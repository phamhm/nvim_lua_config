return {
  {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      -- Initialize mini.ai
      require('mini.ai').setup()

      require('mini.surround').setup()

      require('mini.align').setup()

      require('mini.pairs').setup()
      require('mini.bracketed').setup()

      -- Initialize mini.diff
      require('mini.diff').setup()

      require('mini.files').setup()

      require('mini.statusline').setup({ use_icons=false })

      -- require('mini.trailspace').setup()

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
