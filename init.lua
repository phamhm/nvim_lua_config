require('m_options')
--
--
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.m_notes_path = "~/Documents/notes"
vim.g.m_scripts = "~/Documents/configs/scripts/"

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
  require('m_markdown'),
  require('m_autopair'),
  require('m_surround'),
  require('m_misc'),
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


local ok, my_module = pcall(require, "m_load_poweron")
if ok then
  vim.notify("loaded poweron install app")
end

-- Create the autocommand
vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "Delete all scratch before leaving",
  pattern = "*",
  callback = function()
    local scratch_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/scratch")
    vim.fn.delete(scratch_dir, "rf")
  end,
})
