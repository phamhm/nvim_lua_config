local cmp = require'cmp'

local lspconfig = require'lspconfig'
cmp.setup({
	snippet = {
		-- REQUIRED by nvim-cmp. get rid of it once we can
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<C-k>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		-- TODO: currently snippets from lsp end up getting prioritized -- stop that!
		{ name = 'nvim_lsp' },
	}, {
		{ name = 'path' },
		{ name = 'buffer' },
	}),
	experimental = {
		ghost_text = true,
	},
})

-- Enable completing paths in :
cmp.setup.cmdline(':', {
	sources = cmp.config.sources({
		{ name = 'path' }, 
		{ name = 'buffer' }
	})
})

-- Setup lspconfig.
local on_attach = function(client, bufnr)
	local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
	local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

	--Enable completion triggered by <c-x><c-o>
	buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	local opts = { noremap=true, silent=true }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	buf_set_keymap('n', 'gK', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
	buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
	buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format()<CR>", opts)

	-- None of this semantics tokens business.
	-- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely/
	client.server_capabilities.semanticTokensProvider = nil

	-- Get signatures (and _only_ signatures) when in argument lists.
	require "lsp_signature".on_attach({
		doc_lines = 0,
		handler_opts = {
			border = "none"
		},
	})
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.pyright.setup {}
--lspconfig.rust_analyzer.setup {
	--on_attach = on_attach,
	--flags = {
		--debounce_text_changes = 150,
	--},
	--settings = {
		--["rust-analyzer"] = {
			--cargo = {
				--allFeatures = true,
			--},
			--completion = {
				--postfix = {
					--enable = false,
				--},
			--},
		--},
	--},
	--capabilities = capabilities,
--}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = true,
	signs = true,
	update_in_insert = true,
}
)
