return {
  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  -- {'metalelf0/jellybeans-nvim'},
  {"catppuccin/nvim", name = "catppuccin",
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")

      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "gold", bold = true })

      local border_color = "grey"
      local border_list = {
        -- "SnacksPickerBorder",
        "SnacksPickerInputBorder",
        "SnacksPickerBoxBorder",
        "SnacksInputBorder",
        -- "SnacksInputNormal",
        -- "SnacksInputTitle",
        -- "LineNrAbove",
        -- "LineNrBelow",
        "LineNr",
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
          theme = "auto",
        },
        sections = {
          lualine_a = {},
          lualine_b = {
            function() return vim.fs.basename( vim.v.this_session ) end,
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
