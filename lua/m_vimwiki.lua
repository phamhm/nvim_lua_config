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

        vimwiki = {
          template = "![$FILE_NAME_NO_EXT]($FILE_PATH)",
        },

      }
    },
    keys = {
      -- suggested keymap
      { "<leader>p", function() vim.notify("image paste only works in vimwiki", vim.log.levels.ERROR) end, desc = "clipboard paste" },
    },
  },
  {
    "vimwiki/vimwiki",
    init = function()
      vim.g.vimwiki_global_ext = 0  -- don't treat all md files as vimwiki
      vim.g.vimwiki_listsyms = '.◐✓'
      vim.g.vim_markdown_folding_disabled=0
      vim.g.vimwiki_folding = 'expr'
      -- Vimwiki setup
      local wiki = {
        nested_syntaxes = { python = 'python', rust = 'rust', ['c++'] = 'cpp', c = 'c', bash = 'sh', zsh = 'zsh'  },
        path = vim.g.m_vimwiki_path,
        syntax = 'markdown',
        ext = '.md',
      }

      vim.g.vimwiki_list = { wiki }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "vimwiki", -- Target file type
        callback = function(ev)
          vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>", {buffer = true, noremap = false, silent = true})
          vim.keymap.set("n", "<leader>mt", ":MarkdownPreviewToggle<CR>", {buffer = true, noremap = false, silent = true})
        end,
      })

    end,
  }
}
