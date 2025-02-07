require('lualine').setup {
	options = {
		icons_enabled = false,
		theme = 'jellybeans',
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
		lualine_a = { 'mode', 'PencilMode' },
		lualine_b = {'filename','searchcount', 'selectioncount'},
		lualine_c = { 'branch', 'diff', 'diagnostics'},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {'location',},
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
