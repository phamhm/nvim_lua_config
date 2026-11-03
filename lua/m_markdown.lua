local F = require("utils.functions")
local alt_key = require("utils.functions").format_os_altkey
local map = require("utils.functions").map

local function opts(desc_text)
  return {desc=desc_text, buffer = true, noremap = false, silent = true}
end

local function add_hash()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local current_line = vim.trim(vim.api.nvim_get_current_line())
  if current_line == "" then
    return
  end

  if vim.startswith(current_line, "#") then
    vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { "#" .. current_line })
  else
    vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { "# " .. current_line })
  end
end

local function remove_hash()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local current_line = vim.trim(vim.api.nvim_get_current_line())

  if current_line == "" then
    return
  end

  if vim.startswith(current_line, "#")  then
    vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { vim.trim(string.sub(current_line, 2)) })
  end
end


-- Example keymap binding to <leader>c in normal mode
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ProseMode", { clear = true }),
  -- Target text-focused filetypes (mimicking vim-pencil's default targets)
  pattern = { "markdown"},
  callback = function()
    -- map("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", opts("Markdown Preview Toggle"))
    map("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", opts("Render Markdown Toggle"))
    map({ 'n', 'i' }, alt_key( '<%s-o>' ), '<Cmd>MDListItemBelow<CR>', opts("Mardown list/number below"))
    map({ 'n', 'i' }, '<C-j>', '<Cmd>MDListItemBelow<CR>', opts("Markdown list/number above"))
    map({ 'n', 'i' }, alt_key( '<%s-O>' ), '<Cmd>MDListItemAbove<CR>', opts("Markdown list/number above"))
    map('n', '<C-Space>', '<Cmd>MDTaskToggle<CR>', opts("Markdown task toggle"))

    map('n', '>>', add_hash , opts("promote markdown heading"))
    map('n', '<<', remove_hash, opts("demote markdown heading"))

    map("n", alt_key("<C-%s-f>"), "gwap", opts("format pagraph"))

    map('n', 'gd', vim.lsp.buf.definition, opts("follow markdown link"))

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

    -- vim.opt_local.foldlevel = 9  -- <- set this here instead of treesitter autocmd
  end,
})

return {
  {
    -- [doc](https://github.com/hakonharnes/img-clip.nvim)
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      filetypes = {
        markdown = {
          dir_path = string.format("%s/%s",vim.g.m_notes_path, "assets/images/"),
          use_absolute_path = true,
          template = "![$LABEL]($FILE_PATH)\n\n$CURSOR",
        },
      },
    },
    keys = {
      -- suggested keymap
      -- { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter',},
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    ft = { "markdown.snacks_picker_preview", "markdown"},
    opts = {
      file_types = { 'markdown.snacks_picker_preview', "markdown"},
    },
    config = function()
      require('render-markdown').setup({
        anti_conceal = { enabled = false }
      })
    end
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    config = function()
      require('markdown').setup()
    end,
  }
}
