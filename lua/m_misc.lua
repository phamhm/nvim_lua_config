return {
  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  -- {'metalelf0/jellybeans-nvim'},
  -- {"catppuccin/nvim", name = "catppuccin",
  {"vague-theme/vague.nvim",
    config = function()
      vim.cmd.colorscheme("vague")

      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "orange", bold = true })
      vim.api.nvim_set_hl(0,  "LineNr", { fg = "#a4a4a4", bold = true })
      vim.api.nvim_set_hl(0, 'String', { fg = '#5f894c', italic = false })
      local border_color = "grey"
      local border_list = {
        "SnacksPickerInputBorder",
        "SnacksPickerBoxBorder",
        "SnacksInputBorder",
        "FloatBorder"
      }
      for _, border in ipairs(border_list) do
        vim.api.nvim_set_hl(0, border, { fg= border_color})
      end
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', },

    config = function()
      require('lualine').setup {
        options = {
          theme = "tomorrow_night",
        },
        sections = {
          lualine_a = {
            function() return vim.fs.basename( vim.v.this_session ) end,
          },
          lualine_b = {
            "filename",
            'location',
            'branch',
            'diff',
            'diagnostics'
          },
          lualine_c = {},
          lualine_x = {
            'encoding',
            'fileformat',
            'filetype'
          },
          lualine_y = {}, -- saved 'progress'
          lualine_z = {}
        },
        inactive_sections = {
          lualine_c = {'filename'},
          lualine_x = {'location'},
        },
      }
    end
  }
}
