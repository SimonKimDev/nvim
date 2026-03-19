return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = function()
		local colors = {
			blue = "#65D1FF",
			green = "#3EFFDC",
			violet = "#FF61EF",
			yellow = "#FFDA7B",
			red = "#FF4A4A",
			fg = "#c3ccdc",
			bg = "#112638",
			inactive_bg = "#2c3043",
		}

		local my_lualine_theme = {
			normal = { a = { bg = colors.blue, fg = colors.bg, gui = "bold" } },
			insert = { a = { bg = colors.green, fg = colors.bg, gui = "bold" } },
			visual = { a = { bg = colors.violet, fg = colors.bg, gui = "bold" } },
			command = { a = { bg = colors.yellow, fg = colors.bg, gui = "bold" } },
			replace = { a = { bg = colors.red, fg = colors.bg, gui = "bold" } },
			inactive = { a = { bg = colors.inactive_bg, fg = colors.fg } },
		}
		-- Set the theme for all other components
		my_lualine_theme.normal.b = { bg = colors.bg, fg = colors.fg }
		my_lualine_theme.normal.c = { bg = colors.bg, fg = colors.fg }
		-- Copy normal colors to other modes
		for _, mode in ipairs({ "insert", "visual", "command", "replace" }) do
			my_lualine_theme[mode].b = my_lualine_theme.normal.b
			my_lualine_theme[mode].c = my_lualine_theme.normal.c
		end
		my_lualine_theme.inactive.b = { bg = colors.inactive_bg, fg = colors.fg }
		my_lualine_theme.inactive.c = { bg = colors.inactive_bg, fg = colors.fg }

		return {
			options = {
				theme = my_lualine_theme,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { statusline = { "dashboard", "NvimTree" } },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { { "filename", path = 1 } }, -- Show relative path
				lualine_x = {
					"diagnostics", -- The LSP status component you wanted
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			extensions = { "lazy", "nvim-tree" },
		}
	end,
}
