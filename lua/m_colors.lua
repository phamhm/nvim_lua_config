local group_styles = {
  ["Normal"]        = { fg = "#CCCCCC", bg = "None" },
  ["NormalFloat"]   = { fg = "#CCCCCC", bg = "None" },
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

  ["Error"]         = { fg = "#FFFFFF", bg = "None", bold = true },
  ["QuickFixLine"]  = { fg = "#CCCCCC", bold = true },
  ["Pmenu"]         = { fg = "#DDDDDD", bg = "#222222"  },
  ["PmenuSel"]      = { fg = "#CCCCCC", bg = "#444444" },
  ["Question"]      = { fg = "#666666" },
  ["Directory"]     = { fg = "#777777" },
  ["MsgSeparator"]  = { fg = "#EEEEEE", bg = "#444444" },
  ["MoreMsg"]       = { fg = "#EEEEEE", bg = "#444444" },
  ["StatusLine"]    = { fg = "#EEEEEE", bg = "#333333" },
  ["Folded"]        = { fg = "#444444" },
  ["MatchParen"]    = { fg = "#FFFFFF", bold = true },
  ["WinSeparator"]  = { fg = "#444444" },
  ["Search"]        = { fg = "NvimLightYellow", bg = "None" },
  ["SnippetTabstop"]= { fg = "NvimLightYellow", bg = "None" },
  ["DiagnosticUnnecessary"] = { fg = "#888888" },
  ["Todo"]              = { fg = "NvimLightYellow", bg = "None", bold = true },
  ["@variable"]             = { fg = "#CCCCCC" },
  ["@string.documentation"] = { fg = "#777777" },
  ["@comment.warning"]      = { fg = "#000000", bg = "NvimLightYellow", bold = true },
  ["@comment.error"]        = { fg = "#000000", bg = "NvimLightRed", bold = true },
  ["@comment.note"]         = { fg = "#000000", bg = "#D3EDE7", bold = true },
  ["LspSignatureActiveParameter"] = { bg = "None" },
  ["LspReferenceTarget"]          = { bg = "None" },
  ["NvimTreeGitDeletedIcon"] = { fg = "#87AFD7", bg = "None" },
  ["NvimTreeGitDirtyIcon"]   = { fg = "#87AFD7", bg = "None" },
  ["NvimTreeGitIgnoredIcon"] = { fg = "#87AFD7", bg = "None" },
  ["NvimTreeGitMergeIcon"]   = { fg = "#87AFD7", bg = "None" },
  ["NvimTreeGitNewIcon"]     = { fg = "#87AFD7", bg = "None" },
  ["NvimTreeGitRenamedIcon"] = { fg = "#87AFD7", bg = "None" },
  ["NvimTreeGitStagedIcon"]  = { fg = "#87AFD7", bg = "None" },
}

for group, style in pairs(group_styles) do
  vim.api.nvim_set_hl(0, group, style)
end


-- return { -- doc: https://github.com/wtfox/jellybeans.nvim
--   -- "wtfox/jellybeans.nvim",
--   "vague-theme/vague.nvim",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     vim.cmd.colorscheme("vague")
--
--     local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
--     vim.iter({
--       "MiniFilesNormal",
--       "SnacksPickerList",
--       "SnacksPickerInput",
--     }):each(function(group)
--       vim.api.nvim_set_hl(0, group, { bg = normal_hl.bg})
--     end)
--
--     vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = number_fg, bold = true })
--     vim.api.nvim_set_hl(0, 'String', { fg = "#F2F2F2", bold = false })
--
--     vim.iter( {
--       "SnacksPickerInputBorder",
--       "SnacksPickerBoxBorder",
--       "SnacksInputBorder",
--       "FloatBorder",
--       "SnacksInputTitle",
--       "BlinkCmpMenuBorder",
--       "LazyGitBorder",
--       "LspReferenceTarget",
--       "BlinkCmpMenu",
--     }):each(function(border)
--       vim.api.nvim_set_hl(0, border, { fg= "grey"})
--     end )
--
--     vim.api.nvim_set_hl(0, 'Comment', { fg = "grey", bold = true, italic = false })
--   end
-- },
