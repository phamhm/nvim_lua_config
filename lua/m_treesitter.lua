
function poweron_treesitter()
  -- below code adds additional parser

  local git_user = "phileagleson"
  local git_repo = "tree-sitter-poweron"
  local git_repo_url = "https://github.com/"..git_user.."/"..git_repo
  local parser_config = require("nvim-treesitter.parsers").get_parser_map()
  parser_config.poweron = {
    install_info = {
      url = git_repo_url, -- local path or git repo
      files = {"src/parser.c", "src/scanner.cc"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
      -- optional entries:
      branch = "main", -- default branch in case of git repo if different from master
      generate_requires_npm = false, -- if stand-alone parser without npm dependencies
      requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
    },
    filetype = "poweron", -- if filetype does not match the parser name
  }
  vim.treesitter.language.register('poweron', {'poweron', 'po'})
end



return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", },
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
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
      pattern = languages,
      callback = function(args)
        -- Enable native Neovim treesitter highlighting
        local filetype = args.match
        vim.treesitter.start()

        -- Configure code folding
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"

        -- m_markdown.lua will manage this
        if filetype ~= "markdown" then
          vim.wo.foldlevel = 99
        end

        -- Enable treesitter-based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
