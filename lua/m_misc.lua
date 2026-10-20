local function get_lsp_client()
  local msg = 'No Active LSP'
  local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  if next(clients) == nil then
    return msg
  end

  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
  end

  return table.concat(client_names, '|')
end

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


      require('lualine').setup {
        options = {
          theme = "tomorrow_night",
          component_separators = '',
          section_separators = '',
        },
        sections = {
          lualine_a = {
          },
          lualine_b = {
            function()  return vim.fs.basename( vim.v.this_session ) end,
          },
          lualine_c = {
            {"filename", separator="", path = 1},
            {'filetype', separator="", icon_only=true},
            'location',
            'diff',
            'diagnostics',
            'branch',
          },
          lualine_x = {
          },
          lualine_y = {
            get_lsp_client
          }, -- saved 'progress'
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
