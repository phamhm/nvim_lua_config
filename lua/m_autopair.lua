
return {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      -- 1. Enable fast_wrap
      fast_wrap = {
        map = '<D-e>', -- Shortcut to trigger fastwrap (Alt+e / Option+e)
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%)%>%]%}%, Royal]]]=],
        end_key = 'z',
        before_key = 'h',
        after_key = 'l',
        cursor_pos_before = true,
        keys = '1234567890xycvbnmasdfghjkl',
        manual_position = true,
        highlight = 'Search',
        highlight_grey = 'Comment',
      },
    },
    -- Keep this if you also need nvim-cmp integration
    config = function(_, opts)
      require('nvim-autopairs').setup(opts)

      local cmp_ok, cmp = pcall(require, 'cmp')
      if cmp_ok then
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
      end
    end,
  },
}
