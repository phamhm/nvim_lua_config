local F = require('utils.functions')

local function multicursor_count()
  local ns = vim.api.nvim_create_namespace('nvim.multicursor')
  local mc_count = #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
  if mc_count>0 then
    return string.format("[MC Count:%sx]", mc_count)
  else
    return ""
  end
end

return {
  -- {'easymotion/vim-easymotion'},
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      search = {
        multi_window = false,
      },
    },
    keys = {
      { "S", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "T", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { F.format_os_altkey("<%s-r>"), mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {'nvim-tree/nvim-web-devicons'},
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-mini/mini.icons' },

    config = function()
      require('mini.icons').setup()
      require("mini.icons").mock_nvim_web_devicons()
      local custom_theme = require('lualine.themes.tomorrow_night')

      -- 2. Modify background (bg) colors for specific modes and sections
      -- Sections are structured as: theme.[mode].[section].[attribute]
      local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
      local bg_dec = hl.bg

      -- get colorscheme bg color, then set it to the statusline.
      -- this blends the statusline and the bg
      if bg_dec then
        local bg_hex = string.format("#%06x", bg_dec)
        custom_theme.normal.a.bg = bg_hex
        custom_theme.normal.b.bg = bg_hex
        custom_theme.normal.c.bg = bg_hex
        custom_theme.insert.a.bg = bg_hex
      end

      require('lualine').setup {
        options = {
          theme = custom_theme,
          component_separators = '',
          section_separators = '',
        },
        sections = {
          lualine_a = {
          },
          lualine_b = {
          },
          lualine_c = {
            'location',
            {
              "filename",
              path = 1,
            },
            'branch',
            'diff',
            'diagnostics',
            {
              multicursor_count,
            },
          },
          lualine_x = { },
          lualine_y = { }, -- saved 'progress'
          lualine_z = { }
        },
        inactive_sections = {
          lualine_c = {
            'filename',
          },
          lualine_x = { },
        },
      }
    end
  },
}
