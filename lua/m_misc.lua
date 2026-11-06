local F = require('utils.functions')

local number_fg = "lightgreen"

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
  { -- doc: https://github.com/wtfox/jellybeans.nvim
    "wtfox/jellybeans.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      flat_ui = true,
      italics = false,
      bold    = false,
    },
    config = function()
      vim.cmd.colorscheme("jellybeans-muted")

      local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      vim.api.nvim_set_hl(0, "MiniFilesNormal", { bg = normal_hl.bg})

      vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = number_fg, bold = true })

      local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
      vim.iter( {
        "SnacksPickerInputBorder",
        "SnacksPickerBoxBorder",
        "SnacksInputBorder",
        "FloatBorder",
        "SnacksInputTitle",
        "BlinkCmpMenuBorder",
        "LazyGitBorder",
      }):each(function(border)
        vim.api.nvim_set_hl(0, border, { fg= comment_hl.fg})
      end )
    end
  },
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
            {
              'location',
              color = { fg = number_fg},
            },
            {
              "filename",
              path = 3,
            },
            'branch',
            'diff',
            'diagnostics',
          },
          lualine_x = {
            {
              F.get_status,
              color = { fg = '#ff9e64'},
            },
          },
          lualine_y = {
            function()
              return " " .. os.date("%m/%d/%Y %I:%M%p")
            end,
          }, -- saved 'progress'
          lualine_z = {
          }
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
