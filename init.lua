vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
    print('Installing lazy.nvim....')
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
    print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    {'folke/tokyonight.nvim'},
    {'rebelot/kanagawa.nvim'},
    {'vimwiki/vimwiki'},
    {'preservim/nerdtree'},
    {"vimwiki/vimwiki", 
    init = function() 
        vim.g.vimwiki_global_ext = 0  -- don't treat all md files as vimwiki
        vim.g.vimwiki_listsyms = '.○◐●✓'
        vim.g.vimwiki_folding='expr'
        vim.g.vimwiki_list = {
            {
                path = '~/Dropbox/vimwiki',
                syntax = 'markdown',
                ext = '.md',
            },
        }
    end,
},

{ 'plasticboy/vim-markdown' },
{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
{'williamboman/mason.nvim'},
{'williamboman/mason-lspconfig.nvim'},
{'neovim/nvim-lspconfig'},
{'hrsh7th/cmp-nvim-lsp'},
{'hrsh7th/nvim-cmp'},
{'L3MON4D3/LuaSnip'},
{'tpope/vim-surround'},
{'tpope/vim-fugitive'},
{'easymotion/vim-easymotion'},
{'preservim/nerdcommenter'},
{'jiangmiao/auto-pairs'},
{'nvim-tree/nvim-web-devicons'},
{ "preservim/vim-pencil" ,
    init = function()
        vim.g["pencil#wrapModeDefault"] = "hard"
    end,
},
{'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
{'nvim-telescope/telescope.nvim', tag = '0.1.6', dependencies = { 'nvim-lua/plenary.nvim' },
  }
})

vim.opt.termguicolors = true
require('kanagawa').setup()
vim.cmd.colorscheme('kanagawa')


local lsp_zero = require('lsp-zero')

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = true,
})

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({buffer = bufnr})
end)


require('mason').setup({})
require('mason-lspconfig').setup({
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
    },
})


require('my_keys')
require('lualine_config')
require('vimwiki_config')
require('cmp')
require('my_vim_pencil')
