local F = require("utils.functions")

local m_mini = {
  {
    'echasnovski/mini.ai',
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", },
    version = false,
    lazy = false,
    keys = {
      {"<leader>xm", function() F.NOTIFY(MiniAi.config.search_method) end, desc = "Show MiniAi search method"},
      {"<leader>xa",
        function()
          vim.ui.select(
            {
              'nearest',
              'cover_or_next',
              'next',
              'cover',
              'cover_or_prev',
              'cover_or_nearest',
              'prev',
            },
            {propmt = "Change MiniAi search method"},
            function(search_method)
              if search_method and search_method ~= "" then
                MiniAi.config.search_method = search_method
              end
            end
          )
        end,
        desc = "change Mini Ai Config"
      },
    },
    config = function()
      local ai = require('mini.ai')

      ai.setup({
        search_method = "cover_or_next",
        mappings = {
          goto_left = '[[',
          goto_right = ']]', -- really don't like this
        },
        n_lines = 200, -- Extend search scope for larger textobjects. 50 is fine
        custom_textobjects = {
          -- Function definitions
          -- h = ai.gen_spec.treesitter({
          --   a = '@markup.heading.2.outer',
          --   i = '@markup.heading.2.inner',
          -- }),

          f = ai.gen_spec.treesitter({
            a = '@function.outer',
            i = '@function.inner',
          }),

          -- Function calls (e.g., `func(val)`)
          F = ai.gen_spec.treesitter({
            a = '@call.outer',
            i = '@call.inner',
          }),

          -- Class definitions
          ["/"] = ai.gen_spec.treesitter({
            a = '@comment.outer',
            i = '@comment.inner',
          }),

          -- Class definitions
          C = ai.gen_spec.treesitter({
            a = '@class.outer',
            i = '@class.inner',
          }),

          L = ai.gen_spec.treesitter({
            a = { '@loop.outer' },
            i = { '@loop.inner' },
          }),

          I = ai.gen_spec.treesitter({
            a = { '@conditional.outer' },
            i = { '@conditional.inner' },
          }),

          -- Code blocks, loops, or conditionals
          B = ai.gen_spec.treesitter({
            a = { '@block.outer', },
            i = { '@block.inner', },
          }),

          h = ai.gen_spec.treesitter({
            a = { '@section.outer', },
            i = { '@section.inner', },
          }),
        },
      })
    end
  },
  {
    'echasnovski/mini.align',
    config = function() require("mini.align").setup() end
  },
  {
    'nvim-mini/mini.diff',
    lazy=false,
    config =  function() require("mini.diff").setup({
      view = {
        style = 'sign',
        signs = { add = '┃', change = '┃', delete = '󰗨 ' },
      },
    }
    ) end
  },
  {
    'echasnovski/mini.files',
    config = function()
      require("mini.files").setup({
        options = {
          use_as_default_explorer = false
        },
        windows = {
          preview=true,
          width_preview =  70, -- adjusts dynamically or set to a fixed integer like 40
        },
        mappings = {
          go_in = "<C-l>",
          go_in_plus = "<C-L>",
          go_out = "<C-h>",
          go_out_plus = "<C-H>",
        }
      })
    end
  },
  {
    'echasnovski/mini.sessions',
    dependencies = {  'jedi-knights/yaml.nvim' },
    config = function() require("mini.sessions").setup({
      directory = vim.fn.stdpath('config') .. '/sessions/',
      autowrite = true,
      verbose = {write = true, read = true}
    }) end,
  },
  { 'echasnovski/mini.trailspace', },
  {
    'echasnovski/mini.splitjoin',
    config = function()
      require("mini.splitjoin").setup({
        mappings = {
          toggle = '',
          split = 'gS',
          join = 'gJ',
        },
      })
    end,
  },
  {
    'nvim-mini/mini.cmdline',
    config = function()
      require('mini.cmdline').setup({})
      F.map('c', '<C-j>', F.fn_feedkey("<C-n>"), { expr = true, desc = 'Next history / completion' })
      F.map('c', '<C-k>', F.fn_feedkey("<C-p>"), { expr = true, desc = 'Prev history / completion' })
    end,
  },
}

-- {key, fn, desc, mode}
for _, minimi in ipairs(m_mini) do
  if minimi.keys then
    for _, m_mini_key in ipairs(minimi.keys) do
      m_mini_key.desc = m_mini_key.desc and "[hp]"..m_mini_key.desc or "[hp][Mini no desc]"
    end
  end
end

return m_mini
