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

      -- 2. Configure global capabilities or on_attach logic using standard Neovim autocommands
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Add your keymaps and on_attach logic here
          local opts = { buffer = bufnr }
          -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        end,
      })

      -- 3. Pass specific server settings directly via vim.lsp.config
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })
    end,
  }
}
