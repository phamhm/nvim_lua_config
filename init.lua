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
    {'nanotech/jellybeans.vim'},
    {"HakonHarnes/img-clip.nvim", 
        event = "VeryLazy",
        opts = {
            dir_path = function()
                return vim.fn.expand("%:t:r")
            end,
        },
        keys = {
            -- suggested keymap 
            { "<leader>p", "<cmd>PasteImage<cr>", desc = "clipboard paste" }, 
        },
    },

    {"nvim-treesitter/nvim-treesitter"},
    {'folke/tokyonight.nvim'},
    --{'rebelot/kanagawa.nvim'},
    {'vimwiki/vimwiki'},
    {'preservim/nerdtree'},
    {"vimwiki/vimwiki", 
    init = function() 
        vim.g.vimwiki_global_ext = 0  -- don't treat all md files as vimwiki
        vim.g.vimwiki_listsyms = '.○◐●✓'
        vim.g.vimwiki_folding=''
        vim.g.vimwiki_list = {
            {
                path = 'G:/My Drive/vimwiki',
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
{'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },

{'easymotion/vim-easymotion'},
{'preservim/nerdcommenter'},
{
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
},
{'nvim-tree/nvim-web-devicons'},
{ "preservim/vim-lexical" },
{ "preservim/vim-pencil"},
{ "preservim/vim-litecorrect"},
{ "preservim/vim-textobj-sentence"},
{ "kana/vim-textobj-user"},
--{ "vim-airline/vim-airline-themes"},
--{"vim-airline/vim-airline", 
    --init = function()
        --vim.g.airline_theme='minimalist'
    --end,
--},
{'nvim-telescope/telescope.nvim', tag = '0.1.6', dependencies = { 'nvim-lua/plenary.nvim' } },
})

vim.opt.termguicolors = true
--require('kanagawa').setup()
vim.cmd.colorscheme('jellybeans')

local lsp_zero = require('lsp-zero')

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = false,
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

require('nvim-autopairs').setup({
    -- default values
    --disable_filetype = { "TelescopePrompt", "spectre_panel" },
    --disable_in_macro = true, -- disable when recording or executing a macro
    --disable_in_visualblock = false, -- disable when insert after visual block mode
    --disable_in_replace_mode = true,
    --ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
    --enable_moveright = true,
    --enable_afterquote = true, -- add bracket pairs after quote
    --enable_check_bracket_line = true, --- check bracket in same line
    --enable_bracket_in_quote = true, --
    --enable_abbr = false, -- trigger abbreviation
    --break_undo = true, -- switch for basic rule break undo sequence
    --check_ts = false,
    --map_cr = true,
    --map_bs = true, -- map the <BS> key
    --map_c_h = false, -- Map the <C-h> key to delete a pair
    --map_c_w = false, -- map <c-w> to delete a pair if possible
    fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        before_key = 'h',
        after_key = 'l',
        cursor_pos_before = true,
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        manual_position = true,
        highlight = 'Search',
        highlight_grey='Comment'
                                                                              },
  })

require('my_keys')
require('lualine_config')
require('vimwiki_config')
require('my_vim_pencil')
require('myoptions')
require('cmp_config')
