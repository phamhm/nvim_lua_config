local F = require("utils.functions")
local alt_key = require("utils.functions").format_os_altkey
local map = require("utils.functions").map

local function opts(desc_text, bufnr)
  return {desc=desc_text, buffer = bufnr or true, noremap = false, silent = true}
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
    keys = { },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
  { -- https://github.com/meanderingprogrammer/render-markdown.nvim
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter',},
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    ft = { "markdown.snacks_picker_preview", "markdown"},
    opts = {
      enabled = false,
      file_types = { 'markdown.snacks_picker_preview', "markdown"},
      anti_conceal = { enabled = false }
    },
  },
  { -- https://github.com/jakewvincent/mkdnflow.nvim#statusline-components
    "jakewvincent/mkdnflow.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    config = function()
      require('mkdnflow').setup({
        modules = {
          links = true,
          folds = false,
          foldtext = false,
        },
        on_attach = function(bufnr)
          map("n", alt_key("<%s-f>"), "gwap", opts("format pagraph", bufnr))
          map("n", alt_key("<%s-m>"), "<cmd>RenderMarkdown toggle<CR>", opts("Render Markdown Toggle", bufnr))
          map({'n', 'i'}, '<C-t>', "<cmd>MkdnIndentListItem<CR>" , opts("indent list item", bufnr))
          map({'n', 'i'}, '<C-d>', "<cmd>MkdnDedentListItem<CR>", opts("deindent list", bufnr))


          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.textwidth = 80
          vim.opt_local.wrapmargin = 0
          vim.opt_local.breakindent = true
          vim.opt_local.spell = false
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.softtabstop = 2
        end,
      })
    end,
  }
}
