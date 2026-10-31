local F = require('utils.functions')

local obsidian_commands = {
  "Obsidian check ",
  "Obsidian dailies [OFFSET ...] ",
  "Obsidian dailies ",
  "Obsidian help ",
  "Obsidian helpgrep ",
  "Obsidian new [TITLE] ",
  "Obsidian open [QUERY] ",
  "Obsidian properties [KEY] [VALUE] ",
  "Obsidian today [OFFSET_OR_DATE] ",
  "Obsidian tomorrow ",
  "Obsidian yesterday ",
  "Obsidian new_from_template [TITLE] [TEMPLATE] ",
  "Obsidian quick_switch ",
  "Obsidian rebuild_cache ",
  "Obsidian search [QUERY] ",
  "Obsidian sync [SUBCMD] ",
  "Obsidian tags [TAG ...] ",
  "Obsidian unique_note [TITLE] ",
  "Obsidian workspace [NAME] ",
  "Obsidian backlinks ",
  "Obsidian follow_link [STRATEGY] ",
  "Obsidian toc ",
  "Obsidian footnotes ",
  "Obsidian template [NAME] ",
  "Obsidian paste_img [IMGNAME] ",
  "Obsidian rename [NEWNAME] ",
  "Obsidian toggle_checkbox ",
  "Obsidian extract_note [TITLE] ",
  "Obsidian link [QUERY] ",
  "Obsidian link_new [TITLE] ",
}

local function obsidian_select()
	vim.ui.select(obsidian_commands, {
		prompt = "Obsidian Commands",
	},function(choice)
      if choice == "" or choice == nil then
        return
      end

			local input_place_holder, count = string.gsub(choice, "%b[]", "")
			if count == 0 then
				vim.cmd(choice)
			else
				vim.ui.input({prompt = choice, icon = input_place_holder}, function(input)
					local obsidian_command = input_place_holder .. " " .. input
					vim.cmd(obsidian_command)
				end)
			end
		end)
end

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  ---@type obsidian.config
  config = function()
    require("obsidian").setup {
      legacy_commands = false, -- this will be removed in 4.0.0
      open_notes_in = "current",
      frontmatter = {enabled = false },
      link = { auto_update = true },
      note_id_func = require("obsidian.builtin").title_id,
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H%M",
      },
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
      footer = {enabled = false},
      attachments = {
        folder = "assets"
      }
    }

    F.map("n", "<leader>oo", obsidian_select, {desc="calling obsidian commands"} )
  end
}
