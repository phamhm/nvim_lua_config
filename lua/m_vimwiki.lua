return {
  "vimwiki/vimwiki",
  init = function()
    vim.g.vimwiki_global_ext = 0  -- don't treat all md files as vimwiki
    vim.g.vimwiki_listsyms = '.○◐●✓'
    vim.g.vim_markdown_folding_disabled=1
    -- Vimwiki setup
    local wiki = {
      nested_syntaxes = { python = 'python', rust = 'rust', ['c++'] = 'cpp', c = 'c' },
      path = '~/Documents/vimwiki',
      syntax = 'markdown',
      ext = '.md',
    }

    vim.g.vimwiki_list = { wiki }

    -- Keymap
    vim.keymap.set('n', '<F1>', '<cmd>VimwikiIndex<CR>', { noremap = true, silent = true })

    -- Highlights
    vim.api.nvim_set_hl(0, '@markup.link', { fg = 'cyan', italic = true })
    vim.api.nvim_set_hl(0, 'mkdLink', { fg = 'white', italic = true })

    -- Markdown Autocmds
    local mkd_group = vim.api.nvim_create_augroup('Mkd', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufRead', 'BufWinEnter', 'BufNewFile' }, {
      group = mkd_group,
      pattern = {
        '*.md', '*.mdx', '*.mdown', '*.mkd', '*.mkdn', '*.markdown', '*.mdwn',
        '*.md.*', '*.mdx.*', '*.mdown.*', '*.mkd.*', '*.mkdn.*', '*.markdown.*', '*.mdwn.*',
      },
      callback = function()
        vim.opt_local.syntax = 'markdown'
        vim.opt_local.spell = false
      end,
    })
  end,
}
