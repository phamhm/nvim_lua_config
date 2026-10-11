return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", },
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    local languages = {
      "bash", "zsh",
      "css",
      "dockerfile",
      "go",
      "html",
      "javascript",
      "typescript",
      "json",
      "lua",
      "php",
      "python",
      "scss",
      "sql",
      "vim",
      "yaml",
      "markdown",
      "markdown_inline",
      "regex"
    }

    ts.setup({})

    -- NOTE: If languages fail to install or compilation hangs,
    -- ensure 'tree-sitter-cli' is installed (e.g., :MasonInstall tree-sitter-cli).
    -- If the issue persists, run :checkhealth nvim-treesitter to diagnose.

    -- Use :TSInstall for manuall install languages
    ts.install(languages)

    -- Treesitter features for installed languages must be enabled manually
    vim.api.nvim_create_autocmd("FileType", {
      pattern = languages,
      callback = function()
        -- Enable native Neovim treesitter highlighting
        vim.treesitter.start()

        -- Configure code folding
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
        vim.wo.foldlevel = 99

        -- Enable treesitter-based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
