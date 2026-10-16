return {
  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  -- {'metalelf0/jellybeans-nvim'},
  {"catppuccin/nvim", name = "catppuccin",
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
      vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = '#aaf0c9', bg = '#222222' })
      vim.api.nvim_set_hl(0, 'MiniStatuslineGit', { fg = '#ffffff', bg = '#222222' })
    end
  },
}
