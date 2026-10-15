return {
  {
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
          "bashls"
        } -- your desired servers
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"snacks_picker",  }, -- "snacks_input""snacks_picker_input",
        callback = function()
          vim.b.minicompletion_disable = true
        end,
      })

      -- Pass specific server settings directly via vim.lsp.config
      -- Configure lua_ls natively using the 0.11+ API
      vim.lsp.config('lua_ls', {
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


    end,
  }
}
