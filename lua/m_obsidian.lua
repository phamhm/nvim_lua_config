local F = require('utils.functions')

local obsidian_map = {
  ["Obsidian check "] = " check for common issues in your vault and plugin setup",
  ["Obsidian dailies [OFFSET ...] "] = " open a picker list of daily notes",
  ["Obsidian dailies "] = "2 1 to list daily notes from 2 days ago until tomorrow",
  ["Obsidian help "] = " find files in the plugin help docs",
  ["Obsidian helpgrep "] = " grep files in the plugin help docs",
  ["Obsidian new [TITLE] "] = " create a new note",
  ["Obsidian open [QUERY] "] = " open a note in the Obsidian app",
  ["Obsidian properties [KEY] [VALUE] "] = " get a picker list of frontmatter properties across the vault",
  ["Obsidian today [OFFSET_OR_DATE] "] = " open/create a new daily note",
  ["Obsidian tomorrow "] = " open/create the daily note for the next working day",
  ["Obsidian yesterday "] = " open/create the daily note for the previous working day",
  ["Obsidian new_from_template [TITLE] [TEMPLATE] "] = " create a new note with TITLE from a template with the name TEMPLATE",
  ["Obsidian quick_switch "] = " switch to another note in your vault, searching by its name with a picker",
  ["Obsidian rebuild_cache "] = " force a full cache rescan and flush",
  ["Obsidian search [QUERY] "] = " search for (or create) notes in your vault using ripgrep with your preferred picker",
  ["Obsidian sync [SUBCMD] "] = "use obsidianheadless to access official obsidian sync service. Default off, enable with opts.sync.enabled = true, for more see Sync.",
  ["Obsidian tags [TAG ...] "] = " get a picker list of all occurrences of the given tags",
  ["Obsidian unique_note [TITLE] "] = "create a new note with a unique, timestampbased ID",
  ["Obsidian workspace [NAME] "] = " switch to another workspace",
  ["Obsidian backlinks "] = " get a picker list of references to the current note",
  ["Obsidian follow_link [STRATEGY] "] = " follow a note reference under the cursor",
  ["Obsidian toc "] = " get a picker list of table of contents for current note",
  ["Obsidian footnotes "] = " get a select list of all footnotes in current note, with preview",
  ["Obsidian template [NAME] "] = " insert a template from the templates folder, selecting from a list using your preferred picker",
  ["Obsidian paste_img [IMGNAME] "] = " paste an image from the clipboard into the note at the cursor position by saving it to the vault and adding a markdown image link",
  ["Obsidian rename [NEWNAME] "] = " rename the note of the current buffer or reference under the cursor, updating all backlinks across the vault",
  ["Obsidian toggle_checkbox "] = " cycle through checkbox options",
  ["Obsidian extract_note [TITLE] "] = " extract the visually selected text into a new note and link to it",
  ["Obsidian link [QUERY] "] = " link an inline visual selection of text to a note",
  ["Obsidian link_new [TITLE] "] = " create a new note and link it to an inline visual selection of text",
}

local function obsidian_select()
	local commands = vim.iter(pairs(obsidian_map))
    :map(function(k,v) return k end)
    :fold({}, function(acc, i) table.insert(acc, i) return acc end)
	vim.ui.select(commands, {
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
