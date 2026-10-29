return {
  'saghen/blink.cmp',
  -- Optional: provides snippet support from repositories like friendly-snippets
  dependencies = 'rafamadriz/friendly-snippets',

  -- Use a release tag to download pre-built binaries (avoids needing a Rust toolchain)
  version = 'v1.*', -- Use 'v1' or '1.*' if you want the stable V1 release branch

  ---@module 'blink.cmp'
  ---@type blink.cmp.ConfigOpts
  opts = {
    -- Default keymap preset ('default', 'super-tab', or 'enter')
    keymap = { preset = 'default' },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful if your colorscheme doesn't natively support blink.cmp yet
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      nerd_font_variant = 'mono'
    },

    -- Default list of enabled providers
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
  },
  opts_extend = { "sources.default" }
}
