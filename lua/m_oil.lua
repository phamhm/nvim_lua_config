return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  lazy = false,
  keys = {
    {'<C-D-e>', "<CMD>Oil<CR>", desc = 'Open oil' },
  },
}
