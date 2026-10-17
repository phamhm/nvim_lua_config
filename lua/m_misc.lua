return {
  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  -- {'metalelf0/jellybeans-nvim'},
  {"catppuccin/nvim", name = "catppuccin",
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")

      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "white", bold = true })

      local number_hex = '#ebecf0'
      -- Style the relative numbers above the cursor (e.g., Dim Blue/Grey)
      vim.api.nvim_set_hl(0, "LineNrAbove", { fg = number_hex })
      vim.api.nvim_set_hl(0, "LineNrBelow", { fg = number_hex })

      vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = '#aaf0c9', bg = '#222222' })
      vim.api.nvim_set_hl(0, 'MiniStatuslineGit', { fg = '#ffffff', bg = '#222222' })

      vim.api.nvim_set_hl(0,"SnacksPickerBorder", { fg= "grey"})
      vim.api.nvim_set_hl(0,"SnacksPickerInputBorder", { fg= "grey"})
      vim.api.nvim_set_hl(0,"SnacksPickerBoxBorder", { fg= "grey"})
    end
  },
}
