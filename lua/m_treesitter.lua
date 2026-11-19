return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", },
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local languages = {
      "bash",
      "zsh",
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
      "vimdoc",
      "yaml",
      "markdown",
      "markdown_inline",
      "regex",
      "latex"
    }

    local ts = require("nvim-treesitter")
    ts.setup({
      highlight = {
        enable = true, -- CRITICAL: This must be true
        additional_vim_regex_highlighting = false,
      },
    })

    -- NOTE: If languages fail to install or compilation hangs,
    -- ensure 'tree-sitter-cli' is installed (e.g., :MasonInstall tree-sitter-cli).
    -- If the issue persists, run :checkhealth nvim-treesitter to diagnose.

    -- Use :TSInstall for manuall install languages
    ts.install(languages)

    vim.treesitter.language.register('bash', 'zsh')

    -- Treesitter features for installed languages must be enabled manually
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_filetype", { clear = true }),
      pattern = languages,
      callback = function(args)
        -- Enable native Neovim treesitter highlighting
        local bufnr = args.buf
        local filetype = vim.bo[bufnr].filetype

        local lang = vim.treesitter.language.get_lang(filetype)
        if not lang then
          return
        end

        pcall(vim.treesitter.start, bufnr, lang)

        if ft ~= "markdown" then
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldmethod = "expr"
        end
      end,
    })
  end,
}
