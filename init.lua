require('m_options')
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
  -- {'metalelf0/jellybeans-nvim'},
  {"catppuccin/nvim", name = "catppuccin",
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end
  },
  require('m_snacks'),
  require('m_mini'),
  require('m_lsp'),
  require('m_treesitter'),
  require('m_vimwiki'),
  require('m_autopair'),
  require('m_surround'),

  {"HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    priority = 1,
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
      { "<leader>p", function() vim.notify("image paste only works in vimwiki", vim.log.levels.ERROR) end, desc = "clipboard paste" },
    },
  },

  --{'preservim/nerdtree'},

  {'williamboman/mason.nvim'},

  {'easymotion/vim-easymotion'},
  {'nvim-tree/nvim-web-devicons'},
  {
    -- https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
})

-- setup must be called before loading
-- vim.opt.background = "dark" -- set this to dark or light

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = false,
})

require('m_keys')
