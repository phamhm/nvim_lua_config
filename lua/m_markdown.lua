local alt_key = require("utils.functions").format_os_altkey
local map = require("utils.functions").map
local _inspect = require("utils.functions")._inspect
-- Create an augroup to ensure autocommands don't duplicate on reload
local prose_group = vim.api.nvim_create_augroup("ProseMode", { clear = true })

local function opts(desc_text)
  return {desc=desc_text, buffer = true, noremap = false, silent = true}
end

-- Example keymap binding to <leader>c in normal mode

vim.api.nvim_create_autocmd("FileType", {
  group = prose_group,
  -- Target text-focused filetypes (mimicking vim-pencil's default targets)
  pattern = { "markdown"},
  callback = function()
    -- map("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", opts("Markdown Preview Toggle"))
    map("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", opts("Render Markdown Toggle"))
    map({ 'n', 'i' }, alt_key( '<%s-o>' ), '<Cmd>MDListItemBelow<CR>', opts("Mardown list/number below"))
    map({ 'n', 'i' }, alt_key( '<%s-O>' ), '<Cmd>MDListItemAbove<CR>', opts("Markdown list/number above"))
    -- map('n', '<C-Space>', '<Cmd>MDTaskToggle<CR>', opts("Markdown task toggle"))

    map('n', '<C-.>', "<cmd>.s/^/#/<cr><cmd>noh<cr>", opts("promote markdown heading"))
    map('n', '<C-,>', "<cmd>.s/^#//<cr><cmd>noh<cr>", opts("demote markdown heading"))

    -- Enable soft wrapping
    vim.opt_local.wrap = true
    -- Wrap lines at word boundaries instead of mid-word
    vim.opt_local.linebreak = true
    -- Turn off hard wrapping (prevents Neovim from inserting physical newlines)
    vim.opt_local.textwidth = 80
    vim.opt_local.wrapmargin = 0
    -- Keep indents aligned for wrapped lines (great for nested lists)
    vim.opt_local.breakindent = true

    vim.opt_local.spell = false
  end,
})

return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter',},            -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {enabled = true},
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    config = function()
      require('markdown').setup()
    end,
  }
}
