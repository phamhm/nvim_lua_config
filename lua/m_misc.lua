local utils = require('utils.functions')

return {
  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  -- {'metalelf0/jellybeans-nvim'},
  -- {"catppuccin/nvim", name = "catppuccin",
  {"vague-theme/vague.nvim",
    config = function()
      vim.cmd.colorscheme("vague")

      -- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "orange", bold = true })
      -- vim.api.nvim_set_hl(0,  "LineNr", { fg = "#a4a4a4", bold = true })
      vim.api.nvim_set_hl(0, 'String', { fg = '#5f894c', italic = false })
      -- local border_color = "grey"
      -- local border_list = {
      --   "SnacksPickerInputBorder",
      --   "SnacksPickerBoxBorder",
      --   "SnacksInputBorder",
      --   "FloatBorder"
      -- }
      -- for _, border in ipairs(border_list) do
      --   vim.api.nvim_set_hl(0, border, { fg= border_color})
      -- end
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
      --
      --
      --
      --
      local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
      local bg_dec = hl.bg

      --
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
            'location',
          },
          lualine_c = {
            {
              function()
                return utils.set_title(true)
              end
            },
          },
          lualine_x = {
            'diagnostics',
            'branch',
            'diff',
          },
          lualine_y = {
            function()
              if vim.g.m_todo ~="" then return " " .. vim.g.m_todo
              else return ""
              end
            end,
            function()
              return " " .. os.date("%I:%M%p")
            end,
          }, -- saved 'progress'
          lualine_z = {
          }
        },
        inactive_sections = {
          lualine_c = {'filename'},
          lualine_x = {'location'},
        },
      }
    end
  }
}
