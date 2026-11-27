return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig", -- Kept strictly for server config templates
  },
  config = function()
    -- 1. Initialize mason plugins
    require("mason").setup()

    require("mason-lspconfig").setup({
      ensure_installed = {
        "pyright", -- Python LSP
        "ts_ls",        -- JavaScript/TypeScript LSP
        "lua_ls", -- Lua/Neovim
        "bashls",
      }, -- your desired servers
      automatic_enable = false,
    })

    vim.lsp.config('pyright', {
      filetypes = { 'python'},
      settings = { },
    })

    -- Pass specific server settings directly via vim.lsp.config
    -- Configure lua_ls natively using the 0.11+ API
    vim.lsp.config('lua_ls', {
      filetypes = {"lua"},
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' }, -- Prevents the "undefined global vim" warning
          },
          workspace = {
            checkThirdParty = false,
            library = {
              -- Pass Neovim's runtime files straight into the workspace
              vim.env.VIMRUNTIME,
            },
          },
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.config('ts_ls', {
      cmd = { 'typescript-language-server', '--stdio' },
      filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
      },
      root_markers = {
        'package-lock.json',
        'yarn.lock',
        'pnpm-lock.yaml',
        'bun.lockb',
        'bun.lock',
        '.git',
      },
    })
    
    -- Dynamically activate the server
    vim.lsp.enable({
      'lua_ls',
      'pyright',
      'ts_ls',
    })
  end,
}
