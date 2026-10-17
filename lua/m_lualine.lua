return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons',   "NStefan002/screenkey.nvim" },

  config = function()
    require("screenkey").setup()

    vim.keymap.set("n", "<leader>ts", function()
      require("screenkey").toggle_statusline_component()
    end, { desc = "Toggle screenkey statusline component" })

    require('lualine').setup {
      options = {
        theme = "auto",
      },
      sections = {
        lualine_a = {},
        lualine_b = {"filename", 'location', 'branch', 'diff', 'diagnostics'},
        lualine_c = {function() return require("screenkey").get_keys() end},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {}, -- saved 'progress'
        lualine_z = {}
      },
      inactive_sections = {
        lualine_c = {'filename'},
        lualine_x = {'location'},
      },
    }
  end
}
