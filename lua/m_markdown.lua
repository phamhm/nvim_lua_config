local F = require("utils.functions")
local alt_key = F.alt_key
local map = F.map

local function opts(desc_text, bufnr)
  return {desc="Markdown "..desc_text, buffer = bufnr or true, noremap = false, silent = true}
end

return {
  { -- https://github.com/hakonharnes/img-clip.nvim
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
  -- { -- https://github.com/meanderingprogrammer/render-markdown.nvim
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter',},
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   ft = { "markdown.snacks_picker_preview", "markdown"},
  --   config = function()
  --     require("render-markdown").setup({
  --       enabled = true,
  --       file_types = { 'markdown.snacks_picker_preview', "markdown"},
  --       anti_conceal = {
  --         enabled = false, -- Set to false to stop revealing raw markdown at the cursor
  --       },
  --     })
  --     -- Foreground colors (text color) for H1 through H6
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = '#7dcfff', bold = true })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = '#ff9e3b', bold = true })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = '#9ece6a', bold = true })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = '#7aa2f7', bold = true })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = '#bb9af7', bold = true })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = '#ff007c', bold = true })
  --     -- Background colors (line/box background) for H1 through H6
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { bg = '#162731' })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { bg = '#331c0d' })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { bg = '#1d2715' })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { bg = '#1a2234' })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { bg = '#251c36' })
  --     vim.api.nvim_set_hl(0, 'RenderMarkdownH6Bg', { bg = '#360a2c' })
  --   end
  -- },
  { -- https://github.com/jakewvincent/mkdnflow.nvim#statusline-components
    "jakewvincent/mkdnflow.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    config = function()
      require('mkdnflow').setup({
        modules = {
          links    = true,
          yaml     = true,
          folds    = false,
          foldtext = false,
          conceal  = false,
        },
        cursor = {
          jump_patterns = { "%[%[" },
        },
        on_attach = function(bufnr)
          map({"n", "i" }, alt_key("<%s-t>"), "<cmd>MkdnTableFormat<CR>", opts("format table", bufnr))
          map("n", alt_key("<%s-f>"), "gwap", opts("format pagraph", bufnr))
          -- map("n", alt_key("<%s-m>"), "<cmd>RenderMarkdown toggle<CR>", opts("Render Markdown Toggle", bufnr))

          map({'n', 'i'}, '>>', "<cmd>MkdnIndentListItem<CR>" , opts("indent list item", bufnr))
          map({'n', 'i'}, '<<', "<cmd>MkdnDedentListItem<CR>", opts("deindent list", bufnr))
          map({'n'}, '<leader>sm',
            function()
              local path = vim.fn.expand("%:p")
              F.snacks_grep_markdown(path)
            end, opts("navigate headers", bufnr))

          map("n", "gF", function()
            local line = vim.api.nvim_get_current_line()
            -- Match markdown link syntax: [text](path_or_url)
            local link = line:match("%[.-%]%((.-)%)")

            if link then
              local md_link_item = {text = line, link = link}
              F.open_md_link(md_link_item)
            else
              -- Fallback to default gF behavior if no markdown link is under cursor
              vim.cmd("normal! gF")
            end
          end, opts("Open markdown link or fallback to gF"))

          -- local markdown_group = vim.api.nvim_create_augroup("MarkdownInsert", { clear = true })
          -- -- Automatically enter insert mode when opening or entering a terminal
          -- vim.api.nvim_create_autocmd({ "InsertEnter" }, {
          --   group = markdown_group,
          --   pattern = "*.md",
          --   callback = function()
          --     vim.cmd("RenderMarkdown disable")
          --   end
          -- })

          vim.opt_local.wrap           = true
          vim.opt_local.linebreak      = true
          vim.opt_local.breakindent    = true
          vim.opt_local.breakindentopt    = "list:-1"
          vim.opt_local.number         = false
          vim.opt_local.relativenumber = false
          vim.opt_local.colorcolumn    = ""
        end,
      })
    end,
  }
}
