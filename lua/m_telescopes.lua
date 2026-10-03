return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        telescope.setup({
            -- Your custom configurations go here
            defaults = {
                mappings = {
                    i = { ["<C-c>"] = actions.close, },
                    n = { ["<C-c>"] = actions.close, },
                },
            },
        })
        -- Load the faster native fuzzy searching extension
        telescope.load_extension('fzf')
    end
}
