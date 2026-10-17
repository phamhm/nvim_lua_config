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
}
