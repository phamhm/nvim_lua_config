return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  ---@type obsidian.config
  config = function()
    require("obsidian").setup {
      legacy_commands = false, -- this will be removed in 4.0.0
      link = { auto_update = true },
      note_id_func = require("obsidian.builtin").title_id,
      workspaces = {
        {
          name = "personal",
          path = vim.g.m_notes_path,
        },
        {
          name = "todo",
          path = vim.g.m_notes_path .. '/TODO',
          strict = true,
        },
      },
    }
  end
}
