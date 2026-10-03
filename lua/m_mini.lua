return {
  {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      -- Initialize mini.ai
      require('mini.ai').setup()

      require('mini.surround').setup()

      require('mini.pairs').setup()
      require('mini.bracketed').setup()

      -- Initialize mini.diff
      require('mini.diff').setup()

      require('mini.files').setup()

      require('mini.statusline').setup()
    end,
  },
}
