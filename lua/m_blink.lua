return {
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',

  version = 'v1.*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.ConfigOpts
  opts = {
    keymap = { preset = 'default',
      ['<C-j>'] = { 'select_next', 'fallback'},
      ['<C-k>'] = { 'select_prev', 'fallback' },
    },
    completion = {
      documentation = { auto_show = false },
      menu = {
        border = "rounded",
      },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono'
    },

    sources = {
      min_keyword_length = 3,
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
  },
  opts_extend = { "sources.default" },
}
