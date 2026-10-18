local alt_key = require("utils.functions").format_os_altkey
local bm_line = require("utils.functions").bookmark_line
-- Create an augroup to ensure autocommands don't duplicate on reload
local prose_group = vim.api.nvim_create_augroup("ProseMode", { clear = true })

local function opts(desc_text)
  return {desc=desc_text, buffer = true, noremap = false, silent = true}
end

vim.api.nvim_create_autocmd("FileType", {
  group = prose_group,
  -- Target text-focused filetypes (mimicking vim-pencil's default targets)
  pattern = { "markdown"},
  callback = function()
    vim.keymap.set({ "i", "n" }, alt_key("<%s-p>"), "<cmd>PasteImage<cr>", opts("Paste Image into Markdown Buffer"))
    vim.keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", opts("Markdown Preview Toggle"))
    vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", opts("Render Markdown Toggle"))
    vim.keymap.set({ 'n', 'i' }, alt_key( '<%s-o>' ), '<Cmd>MDListItemBelow<CR>', opts("Mardown list/number below"))
    vim.keymap.set({ 'n', 'i' }, alt_key( '<%s-O>' ), '<Cmd>MDListItemAbove<CR>', opts("Markdown list/number above"))

    vim.keymap.set('n',"<leader>bm",
      function()
        -- move the mddownlink to the bookmarks file
        bm_line(vim.g.m_notes_path .. '/' .. 'bookmarks.md')
      end, opts("Move markdown link to the bookmarks.md file"))

    -- 1. Enable soft wrapping
    vim.opt_local.wrap = true

    -- 2. Wrap at words instead of hard character boundaries
    vim.opt_local.linebreak = true

    -- 3. Maintain indentation when text wraps to the next visual line
    vim.opt_local.breakindent = true

    -- 4. Enable spell checking (optional, but standard for text mode)
    vim.opt_local.spell = true

    -- 6. Punctuation undo sequences (Mimics vim-pencil's granular undo)
    -- Creates an undo point every time you hit a punctuation mark or Space
    local punctuations = { ",", ".", "!", "?", ";", " " }
    for _, char in ipairs(punctuations) do
      vim.keymap.set("i", char, char .. "<c-g>u", opts("Punctuation undo sequences (Mimics vim-pencil's granular undo)"))
    end
  end,
})

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
    opts = {},
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    config = function()
      require('markdown').setup()
    end,
  }
}
