return {
  "vimwiki/vimwiki",
  init = function()
    vim.g.vimwiki_global_ext = 0  -- don't treat all md files as vimwiki
    vim.g.vimwiki_listsyms = '.◐✓'
    vim.g.vim_markdown_folding_disabled=1
    -- Vimwiki setup
    local wiki = {
      nested_syntaxes = { python = 'python', rust = 'rust', ['c++'] = 'cpp', c = 'c' },
      path = vim.g.m_vimwiki_path,
      syntax = 'markdown',
      ext = '.md',
    }

    vim.g.vimwiki_list = { wiki }

    -- Keymap
    vim.keymap.set('n', '<F1>', '<cmd>VimwikiIndex<CR>', { noremap = true, silent = true })

    -- Highlights
    -- vim.api.nvim_set_hl(0, '@markup.link', { fg = 'cyan', italic = true })
    -- vim.api.nvim_set_hl(0, 'mkdLink', { fg = 'white', italic = true })

    -- Markdown Autocmds

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "vimwiki", -- Target file type
      callback = function()
        vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<CR>", { desc = "clipboard paste" })
      end,
    })

  end,
}
