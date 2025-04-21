return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local treesitter = require("nvim-treesitter.configs")

		treesitter.setup({
			ensure_installed = {
				"c",
				"lua",
				"vim",
				"vimdoc",
				"elixir",
				"javascript",
				"python",
				"typescript",
				"go",
				"svelte",
				"css",
				"html",
				"json",
				"yaml",
				"xml",
				"c_sharp",
				"powershell",
				"java",
				"gitignore",
				"dockerfile",
				"tsx",
				"markdown",
				"markdown_inline",
				"query",
			},
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},
			autotag = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
