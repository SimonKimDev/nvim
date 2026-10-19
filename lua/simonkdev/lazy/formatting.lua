-- ~/.config/nvim/lua/simonkdev/lazy/formatting.lua
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },

	keys = {
		{
			"<leader>mp",
			function()
				require("conform").format({
					async = false,
					timeout_ms = 8000,
				})
			end,
			mode = { "n", "v" },
			desc = "Format file or range",
		},
	},

	opts = {
		-- Filetypes without a formatter here use their LSP's formatter, e.g. Roslyn for C#.
		-- Set as a default so filetype entries can override it; options passed to format() would win.
		default_format_opts = {
			lsp_format = "fallback",
		},

		formatters_by_ft = {
			-- Roslyn formats C# but can leave trailing whitespace, so trim after it.
			cs = { "trim_whitespace", "trim_newlines", lsp_format = "first" },
			-- Every filetype not listed here.
			_ = { "trim_whitespace", "trim_newlines", lsp_format = "first" },
			-- Trailing spaces are part of a patch's context lines. An empty table would fall through to "_".
			diff = { lsp_format = "fallback" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			lua = { "stylua" },
			go = { "goimports" }, -- gofmt plus adding/removing imports
		},

		format_on_save = {
			timeout_ms = 8000,
		},
	},
}
