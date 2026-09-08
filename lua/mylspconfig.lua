--local capabilities = require("cmp_nvim_lsp").default_capabilities()

return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig", -- Kept strictly for server config templates
    },
    config = function()
      -- 1. Initialize Mason
      require("mason").setup()

      -- 2. Ensure language servers are downloaded locally via Mason
      require("mason-lspconfig").setup({
        ensure_installed = {
          "basedpyright", -- Python LSP
          "ts_ls",        -- JavaScript/TypeScript LSP
          "lua_ls", -- Lua/Neovim
        },
      })

      -- 3. Unified Keymaps (Triggers automatically via native LspAttach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)          -- Go to definition
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)          -- Find references
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)                -- Show documentation
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)      -- Smart rename
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- Code actions
        end,
      })

      -- 4. Extensible Capabilities for Autocomplete (e.g., nvim-cmp or blink.cmp)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_lsp.default_capabilities()
      end

      -- 5. Native Neovim 0.11+ LSP initialization (Zero lspconfig requires!)
      local servers = { "basedpyright", "ts_ls" }

      for _, server in ipairs(servers) do
        -- Modifies server config with your client capabilities
        vim.lsp.config(server, {
          capabilities = capabilities,
        })
        -- Enforce native activation across file types
        vim.lsp.enable(server)
      end
    end,
  }
}
