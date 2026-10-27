local F = require('utils.functions')

return {
  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  -- {'metalelf0/jellybeans-nvim'},
  -- {"catppuccin/nvim", name = "catppuccin",
  -- { "rebelot/kanagawa.nvim",
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('kanso').setup({
        italic = false,
        bold = false,
        commentStyle = { italic = false, bold = false },
        functionStyle = { bold = false },
        keywordStyle = { italic = false, bold = false },
        statementStyle = { bold = false },
        typeStyle = { italic = false, bold = false },
      })
      vim.cmd.colorscheme("kanso-zen")
      local border_list = {
        "SnacksPickerInputBorder",
        "SnacksPickerBoxBorder",
        "SnacksInputBorder",
        "FloatBorder",
        "SnacksInputTitle"
      }
      local hl = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
      for _, border in ipairs(border_list) do
        vim.api.nvim_set_hl(0, border, { fg= hl.fg})
      end
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#DAB1DA", bold = false })
      -- vim.api.nvim_set_hl(0,  "LineNr", { fg = "#DAB1DA", bold = false })
    end
  },
  -- {"vague-theme/vague.nvim",
  --   config = function()
  --
  --     require('vague').setup({
  --       bold = false, -- Disable bold globally
  --       italic = false, -- Disable italic globally
  --     })
  --     vim.cmd.colorscheme("vague")
  --
  --     -- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "orange", bold = true })
  --     -- vim.api.nvim_set_hl(0,  "LineNr", { fg = "#a4a4a4", bold = true })
  --     -- vim.api.nvim_set_hl(0, 'String', { fg = '#5f894c', italic = false })
  --     -- local border_color = "grey"
  --     -- local border_list = {
  --     --   "SnacksPickerInputBorder",
  --     --   "SnacksPickerBoxBorder",
  --     --   "SnacksInputBorder",
  --     --   "FloatBorder"
  --     -- }
  --     -- for _, border in ipairs(border_list) do
  --     --   vim.api.nvim_set_hl(0, border, { fg= border_color})
  --     -- end
  --   end
  -- },
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
              F.set_title,
            },
            'diagnostics',
            'branch',
            'diff',
            {
              function()
                if vim.g.m_todo ~="" then return MiniIcons.get("file", "TODO") .. " " .. vim.g.m_todo
                else return ""
                end
              end,
              color = { fg = '#ff9e64'},

            }
          },
          lualine_x = {
            {
              function()
                if vim.g.global_status ~= "" then
                  return vim.g.global_status
                else
                  return ""
                end
              end,
              color = { fg = '#ff9e64'},
            },
          },
          lualine_y = {
            function()
              return " " .. os.date("%I:%M%p")
            end,
          }, -- saved 'progress'
          lualine_z = {
          }
        },
        inactive_sections = {
          lualine_c = {
            'location',
            {
              function()
                return F.set_title()
              end
            },
          },
          lualine_x = { },
        },
      }
    end
  }
}
