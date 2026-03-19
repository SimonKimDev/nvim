return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	-- Use the 'opts' table for a more declarative setup
	opts = {
		ensure_installed = {
			"c",
            "c_sharp",
			"lua",
			"vim",
			"vimdoc",
			"javascript",
			"typescript",
			"python",
			"go",
			"css",
			"html",
			"json",
			"yaml",
			"xml",
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
	},
	-- Add a config function to ensure autotag is enabled
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
