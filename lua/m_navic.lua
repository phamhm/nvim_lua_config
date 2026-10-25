return {
  "SmiteshP/nvim-navic",
  dependencies = {"LunarVim/breadcrumbs.nvim"},
  config = function()
    require("nvim-navic").setup {
      lsp = {
        auto_attach = true,
      },
    }

    require("breadcrumbs").setup()

    -- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
  end
}
