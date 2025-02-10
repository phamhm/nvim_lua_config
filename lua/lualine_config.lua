require('lualine').setup {
	options = {
		icons_enabled = false,
		theme = 'auto',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = false,
		refresh = {
			statusline = 100,
			tabline = 100,
			winbar = 100,
		}
	},
	sections = {
		lualine_a = {},

		lualine_b = {
            {
                'filename',
                file_status = true,      -- Displays file status (readonly status, modified status)
                newfile_status = true,  -- Display new file status (new file means no write after created)
                path = 0,                -- 0: Just the filename 1: Relative path 2: Absolute path 3: Absolute path, with tilde as the home directory 4: Filename and parent dir, with tilde as the home directory
                shorting_target = 20,    -- Shortens path to leave 40 spaces in the window
                -- for other components. (terrible name, any suggestions?)
                symbols = {
                    modified = '[+]',      -- Text to show when the file is modified.
                    readonly = '[READ ONLY]',      -- Text to show when the file is non-modifiable or readonly.
                    unnamed = '[No Name]', -- Text to show for unnamed buffers.
                    newfile = '[New]',     -- Text to show for newly created file before first write
                }
            },
            'PencilMode',
            'location', 
			'searchcount', 'selectioncount', 
		},

		lualine_c = { 'branch', 'diff', 'diagnostics'},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {},
        lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {}
}
