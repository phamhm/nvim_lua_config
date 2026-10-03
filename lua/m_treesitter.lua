return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Automatically updates parsers when the plugin updates
    config = function()
      local configs = require("nvim-treesitter")

      configs.setup({
        -- A list of parser names, or "all" to install everything
        ensure_installed = { "lua",
        "vim",
        "vimdoc",
        "query",
        "javascript",
        "typescript",
        "c",
        "rust",
        "markdown",
        "markdown_inline"
      },


        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering a buffer
        auto_install = true,

        -- Syntax highlighting configuration
        highlight = {
          enable = true, -- false will disable the whole extension

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set to `true` if you depend on 'syntax' being enabled (like for folds).
          additional_vim_regex_highlighting = false,
        },

        -- Indentation configuration (experimental but highly recommended)
        indent = {
          enable = true
        },
      })
    end,
  }
}
