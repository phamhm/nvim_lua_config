--
--
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.m_vimwiki_path = "~/Documents/vimwiki"

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
  require('m_lsp'),
  require('m_treesitter'),
  require('m_vimwiki'),
  -- require('m_gitsign'),

  -- {'rktjmp/lush.nvim'},
  -- {'metalelf0/jellybeans-nvim'},
  {"catppuccin/nvim", name = "catppuccin", priority = 1000 },
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

  --{'preservim/nerdtree'},

  {'williamboman/mason.nvim'},

  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  -- { "preservim/vim-lexical" },
  -- { "preservim/vim-pencil"},
  -- { "preservim/vim-litecorrect"},
  -- { "preservim/vim-textobj-sentence"},
  -- { "kana/vim-textobj-user"},
  { 'preservim/vim-markdown',
    config = function()
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_folding_style_pythonic = 1
      vim.g.vim_markdown_no_default_key_mappings = 1
      vim.g.vim_markdown_new_list_item_indent = 0
    end,
  },
  {
    -- https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim', 'nvim-mini/mini.icons', 'nvim-tree/nvim-web-devicons' },            -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function()
      require('render-markdown').setup({
        enabled = false,
        file_types = { 'markdown', 'vimwiki' },
        render_modes = { 'n', 'c', 't' },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"vimwiki", "markdown"}, -- Target file type
        callback = function(ev)
          -- Map 'K' to show LSP hover documentation, only in Lua files
          vim.keymap.set('n', '<leader>mt', function()
            require('render-markdown').toggle()
          end, { desc = 'Toggle Markdown Rendering (Global)' })
        end,
      })

    end,
  }
})

-- setup must be called before loading
-- vim.opt.background = "dark" -- set this to dark or light
vim.cmd.colorscheme("catppuccin-mocha")

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = false,
})

require('m_keys')
-- require('m_vimpencil')
require('m_options')

-- prevent snacks from create history
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("no_picker_hist", { clear = true }),
  callback = function()
    require("snacks.picker.util.history") -- Preload file
    vim.api.nvim_clear_autocmds({ group = "snacks_history" })
  end,
})
