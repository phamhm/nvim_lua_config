return {
  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  -- {'metalelf0/jellybeans-nvim'},
  {"catppuccin/nvim", name = "catppuccin",
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end
  },
}
