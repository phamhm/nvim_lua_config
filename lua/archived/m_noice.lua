-- lazy.nvim
return { --https://github.com/folke/noice.nvim
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("noice").setup({
      lsp = {
        hover = {
          enabled = true, -- Ensure Noice is handling hover
          silent = false, -- Set to true to eliminate hover notifications if missing documentation
        },
      },

      views = {
        hover = {
          border = {
            style = "rounded", -- Options: "none", "single", "double", "rounded", "solid", "shadow"
            -- padding = { 0, 1 },
          },
          position = { row = 2, col = 0 }, -- Adjusts position relative to the cursor
        },
      },

      popupmenu = {
        enabled = true,
        ---@type 'nui'|'cmp'
        backend = "nui", -- use 'nui' instead of 'cmp' if nvim-cmp is removed/replaced
      },
      presets = {
        command_palette = true,
      },
    })
  end
}
