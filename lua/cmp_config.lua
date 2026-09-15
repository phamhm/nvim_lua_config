--local cmp = require('cmp')
----local cmp_action = require('lsp-zero').cmp_action()
--local cmp_autopairs = require('nvim-autopairs.completion.cmp')

--cmp.setup({
    --mapping = cmp.mapping.preset.insert({
        ---- `Enter` key to confirm completion
        --['<CR>'] = cmp.mapping.confirm({select = false}),

        ---- Ctrl+Space to trigger completion menu
        --['<C-Space>'] = cmp.mapping.complete(),

        ---- Navigate between snippet placeholder
        ----['<C-n>'] = cmp_action.luasnip_jump_forward(),
        ----['<C-p>'] = cmp_action.luasnip_jump_backward(),

        ---- Scroll up and down in the completion documentation
        --['<C-u>'] = cmp.mapping.scroll_docs(-4),
        --['<C-d>'] = cmp.mapping.scroll_docs(4),
    --}),
    --snippet = {
        --expand = function(args)
            ----require('luasnip').lsp_expand(args.body)
        --end,
    --},
--})


--cmp.event:on(
    --'confirm_done',
    --cmp_autopairs.on_confirm_done()
--)



return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-vsnip",
        "hrsh7th/vim-vsnip",
    },
    config = function()
        local cmp = require("cmp")

        cmp.setup({
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),

                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp", keyword_length = 3 },
                { name = "vsnip", keyword_length = 3 },
            }, {
                { name = "buffer", keyword_length = 3 },
                { name = "path"},
            }),
        })
    end,
}

