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
{'preservim/nerdtree'},
{"vimwiki/vimwiki",
--{'vimwiki/vimwiki'},
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

--{'L3MON4D3/LuaSnip'},
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
{'nvim-telescope/telescope.nvim', tag = '0.1.6', dependencies = { 'nvim-lua/plenary.nvim' } },
})

vim.opt.termguicolors = true
-- Default options:

-- setup must be called before loading
vim.cmd("colorscheme jellybeans-nvim")

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = false,
})


-- https://github.com/windwp/nvim-autopairs
require('nvim-autopairs').setup({
    -- default values
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    disable_in_macro = true, -- disable when recording or executing a macro
    --disable_in_visualblock = false, -- disable when insert after visual block mode
    --disable_in_replace_mode = true,
    --ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
    enable_moveright = true,
    enable_afterquote = true, -- add bracket pairs after quote
    --enable_check_bracket_line = true, --- check bracket in same line
    --enable_bracket_in_quote = true, --
    --enable_abbr = false, -- trigger abbreviation
    --break_undo = true, -- switch for basic rule break undo sequence
    check_ts = true,
    --map_cr = true, -- true is default
    --map_bs = true, -- true is default, map the <BS> key
    map_c_h = true, -- Map the <C-h> key to delete a pair
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
--require('my_luasnip')

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Removes trailing whitespace on save',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})
