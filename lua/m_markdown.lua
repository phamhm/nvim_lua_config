local F = require("utils.functions")
local alt_key = require("utils.functions").format_os_altkey
local map = require("utils.functions").map

local function opts(desc_text, bufnr)
  return {desc="Markdown "..desc_text, buffer = bufnr or true, noremap = false, silent = true}
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
          map({'n', 'i'}, '>>', "<cmd>MkdnIndentListItem<CR>" , opts("indent list item", bufnr))
          map({'n', 'i'}, '<<', "<cmd>MkdnDedentListItem<CR>", opts("deindent list", bufnr))


          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.textwidth = 80
          vim.opt_local.wrapmargin = 0
          vim.opt_local.breakindent = true
          vim.opt_local.spell = false
        end,
      })
    end,
  }
}
