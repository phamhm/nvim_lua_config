--
--
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
    require('m_snacks'),

    require('m_mini'),

    require('cmp_config'),

    require('mylspconfig'),

    --schemes

    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL", "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },


    {'rktjmp/lush.nvim'},
    {'metalelf0/jellybeans-nvim'},
    {"HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
        default = {
            dir_path = function()
                return  "assets/images/" .. vim.fn.expand("%:t:r")
            end,
            file_name = "%Y-%m-%d-%H-%M-%S", -- timestamp format
            extension = "png",
        }
    },
    keys = {
        -- suggested keymap
        { "<leader>p", "<cmd>PasteImage<cr>", desc = "clipboard paste" },
    },
},

{"nvim-treesitter/nvim-treesitter"},
--{'preservim/nerdtree'},
{"vimwiki/vimwiki",
init = function()
    vim.g.vimwiki_global_ext = 0  -- don't treat all md files as vimwiki
    vim.g.vimwiki_listsyms = '.○◐●✓'
    --vim.g.vimwiki_folding=''
    vim.g.vim_markdown_folding_disabled=1
    vim.g.vimwiki_list = {
        {
            path = '~/Documents/vimwiki',
            syntax = 'markdown',
            ext = '.md',
        },
    }
end,
},

{'williamboman/mason.nvim'},

{'easymotion/vim-easymotion'},
{'nvim-tree/nvim-web-devicons'},
{ "preservim/vim-lexical" },
{ "preservim/vim-pencil"},
{ "preservim/vim-litecorrect"},
{ "preservim/vim-textobj-sentence"},
{ "kana/vim-textobj-user"},
{ 'preservim/vim-markdown',
config = function()
    vim.g.vim_markdown_conceal_code_blocks = 0
    vim.g.vim_markdown_folding_style_pythonic = 1
    vim.g.vim_markdown_no_default_key_mappings = 1
    vim.g.vim_markdown_new_list_item_indent = 0
end,
},
{ "iamcco/markdown-preview.nvim",
--https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file
cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
build = "cd app && yarn install",
init = function()
    vim.g.mkdp_filetypes = { "markdown" }
end,
ft = { "markdown" },
},

})

vim.opt.termguicolors = true
-- Default options:

-- setup must be called before loading
vim.opt.background = "dark" -- set this to dark or light
vim.cmd.colorscheme "jellybeans-nvim"

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = false,
})

require('my_keys')
require('vimwiki_config')
require('my_vim_pencil')
require('myoptions')

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Removes trailing whitespace on save',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})

