local M = require("utils.markdowns")
local F = require("utils.functions")
local alt_key = require("utils.functions").format_os_altkey
local map = require("utils.functions").map
-- Create an augroup to ensure autocommands don't duplicate on reload
local prose_group = vim.api.nvim_create_augroup("ProseMode", { clear = true })

local function opts(desc_text)
  return {desc=desc_text, buffer = true, noremap = false, silent = true}
end

local function ensure_checkbox()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  -- Check if the line starts with "- [ ]"
  if not vim.startswith(line, "- [ ]") then
    local new_line = "- [ ] " .. line
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  end
end

-- Example keymap binding to <leader>c in normal mode

vim.api.nvim_create_autocmd("FileType", {
  group = prose_group,
  -- Target text-focused filetypes (mimicking vim-pencil's default targets)
  pattern = { "markdown"},
  callback = function()
    map({ "i", "n" }, alt_key("<%s-p>"), "<cmd>PasteImage<cr>", opts("Paste Image into Markdown Buffer"))
    map("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", opts("Markdown Preview Toggle"))
    map("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", opts("Render Markdown Toggle"))
    map({ 'n', 'i' }, alt_key( '<%s-o>' ), '<Cmd>MDListItemBelow<CR>', opts("Mardown list/number below"))
    map({ 'n', 'i' }, alt_key( '<%s-O>' ), '<Cmd>MDListItemAbove<CR>', opts("Markdown list/number above"))
    map('n', '<C-Space>', '<Cmd>MDTaskToggle<CR>', opts("Markdown task toggle"))

    -- map('n', '<Cr>', function()
    --   local current_line = vim.api.nvim_get_current_line()
    --   local text, link = M.match_single_link(current_line)
    --   if text~=nil and link~=nil then
    --     local res = F.open_md_link({text=text, link=link})
    --     if not res then
    --       vim.lsp.buf.definition()
    --     end
    --   else
    --     vim.lsp.buf.definition()
    --   end
    -- end, opts("Markdown task toggle"))

    map('n', '<C-.>', "<cmd>.s/^/#/<cr><cmd>noh<cr>", opts("promote markdown heading"))
    map('n', '<C-,>', "<cmd>.s/^#//<cr><cmd>noh<cr>", opts("demote markdown heading"))

    map('n', '<leader>mc', ensure_checkbox, opts("make check box"))

    -- Enable soft wrapping
    vim.opt_local.wrap = true
    -- Wrap lines at word boundaries instead of mid-word
    vim.opt_local.linebreak = true
    -- Turn off hard wrapping (prevents Neovim from inserting physical newlines)
    vim.opt_local.textwidth = 0
    vim.opt_local.wrapmargin = 0
    -- Keep indents aligned for wrapped lines (great for nested lists)
    vim.opt_local.breakindent = true

    vim.opt_local.spell = false

    -- 6. Punctuation undo sequences (Mimics vim-pencil's granular undo)
    -- Creates an undo point every time you hit a punctuation mark or Space
    -- local punctuations = { ",", ".", "!", "?", ";", " " }
    -- for _, char in ipairs(punctuations) do
    --   vim.keymap.set("i", char, char .. "<c-g>u", opts("Punctuation undo sequences (Mimics vim-pencil's granular undo)"))
    -- end
  end,
})


-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function()
--     -- Option A: Switch to an entirely different colorscheme for markdown
--     vim.cmd.colorscheme("zen")
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("BufLeave", {
--   pattern = "*.md",
--   callback = function()
--     -- Option A (cont.): Switch back to your default colorscheme when leaving markdown files
--     vim.cmd.colorscheme("vague")
--   end,
-- })

return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
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
      },
      filetypes = {
        markdown = {
          template = "![$FILE_NAME_NO_EXT]($FILE_PATH)",
        },
      }
    },
    keys = {
      -- suggested keymap
      -- { "<leader>p", function() vim.notify("image paste only works in markdown", vim.log.levels.ERROR) end, desc = "clipboard paste" },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter',},            -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {enabled = false},
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    config = function()
      require('markdown').setup()
    end,
  }
}
