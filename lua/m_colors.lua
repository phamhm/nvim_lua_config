local m_group_styles = {
  -- ["Normal"]        = { fg = "#CCCCCC", bg = "None" },
  -- ["NormalFloat"]   = { fg = "#CCCCCC", bg = "None" },
  ["String"]        = { fg = "#D6DFD4" },
  ["Comment"]       = { fg = "#777777" },
  ["Visual"]        = { fg = "#000000", bg = "#888888"},
  ["Identifier"]    = { fg = "#DDDDDD", bold = true },
  ["Statement"]     = { fg = "#EEEEEE", bold = true },
  ["Special"]       = { fg = "#87AFD7", bold = false },
  ["Function"]      = { fg = "#87AFD7" },
  ["Constant"]      = { fg = "#CCCCCC" },
  ["DiffAdd"]       = { fg = "None", bg = "#000022", sp = "None" },
  ["DiffDelete"]    = { fg = "#666666" },
  ["DiffText"]      = { fg = "NvimLightYellow", bg = "None", sp = "None" },
  ["DiffChange"]    = { fg = "None", bg = "None" },
  ["Changed"]       = { fg = "#EEEEEE", bg = "None" },


  ["@markup.link.url"]   = {  bold = true },
  ["@markup.link.label"] = { fg    = "lightgreen" },

  RenderMarkdownH1       = { fg    = '#f38ba8', bold     = true },
  RenderMarkdownH2       = { fg    = '#fab387', bold     = true },
  RenderMarkdownH3       = { fg    = '#f9e2af', bold     = true },
  RenderMarkdownH4       = { fg    = '#a6e3a1', bold     = true },
  RenderMarkdownH5       = { fg    = '#89b4fa', bold     = true },
  RenderMarkdownH6       = { fg    = '#cba6f7', bold     = true },
  -- Subtle tinted backgrounds for full-width header bars
  RenderMarkdownH1Bg     = { bg    = '#3b262c' },
  RenderMarkdownH2Bg     = { bg    = '#3d2f26' },
  RenderMarkdownH3Bg     = { bg    = '#3d3826' },
  RenderMarkdownH4Bg     = { bg    = '#28382c' },
  RenderMarkdownH5Bg     = { bg    = '#253042' },
  RenderMarkdownH6Bg     = { bg    = '#332942' },
}

return { -- doc: https://github.com/wtfox/jellybeans.nvim
  -- "wtfox/jellybeans.nvim",
  "vague-theme/vague.nvim",
  -- "folke/tokyonight.nvim",

  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("vague")

    local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    vim.iter({
      "MiniFilesNormal",
      "SnacksPickerList",
      "SnacksPickerInput",
    }):each(function(group)
      vim.api.nvim_set_hl(0, group, { bg = normal_hl.bg})
    end)

    vim.iter( {
      "SnacksPickerInputBorder",
      "SnacksPickerBoxBorder",
      "SnacksInputBorder",
      "FloatBorder",
      "SnacksInputTitle",
      "BlinkCmpMenuBorder",
      "LazyGitBorder",
      "LspReferenceTarget",
      "BlinkCmpMenu",
    }):each(function(border)
      vim.api.nvim_set_hl(0, border, { fg= "grey"})
    end )

    vim.api.nvim_set_hl(0, 'Comment', { fg = "grey", bold = true, italic = false })
    for group, style in pairs(m_group_styles) do
      vim.api.nvim_set_hl(0, group, style)
    end
  end }
