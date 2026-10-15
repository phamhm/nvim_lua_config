return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    -- 1. Enable fast_wrap
    fast_wrap = {
      map = '<D-e>', -- Shortcut to trigger fastwrap (Alt+e / Option+e)
      end_key = 'z',
      keys = '1234567890xycvbnmasdfghjkl',
    },
  },
}
