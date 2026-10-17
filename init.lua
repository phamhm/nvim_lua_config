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
  require('m_snacks'),
  require('m_mini'),
  require('m_lsp'),
  require('m_treesitter'),
  require('m_vimwiki'),
  require('m_autopair'),
  require('m_surround'),
  require('m_misc')
})

-- setup must be called before loading
-- vim.opt.background = "dark" -- set this to dark or light

vim.diagnostic.config({
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
    prefix = "●",
  },
  signs = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  update_in_insert = false,
  underline = false,
})

require('m_keys')
