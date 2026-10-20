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
      local custom_theme = require('lualine.themes.tomorrow_night')

      -- 2. Modify background (bg) colors for specific modes and sections
      -- Sections are structured as: theme.[mode].[section].[attribute]
      custom_theme.normal.a.bg = 'None'
      custom_theme.normal.b.bg = 'None'
      custom_theme.normal.c.bg = 'None' -- Modifies the center/entire bar background
      custom_theme.insert.a.bg = 'None'

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
            -- {'filetype', separator="", icon_only=true},
            -- {"filename", separator="", path = 1},
            {
              function()
                local fname = vim.fn.expand('%:t')
                local icon = MiniIcons.get('file', fname).. ' '

                fname = icon .. vim.fn.expand('%:p:h:t')..'/' .. fname
                if vim.bo.modified then
                  fname = fname .. ' [+]'
                end

                if vim.bo.readonly or not vim.bo.modifiable then
                   fname = fname .. ' [-]'
                end
                return fname

              end
            },
            'location',
            'diagnostics',
            'branch',
            'diff',
          },
          lualine_x = {
            function()  return vim.fs.basename( vim.v.this_session ) end,
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
