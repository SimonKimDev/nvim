return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- The only mason-lspconfig setup() call: a second call replaces this list instead of extending it.
		mason_lspconfig.setup({
			ensure_installed = {
				"html",
				"lua_ls",
				"cssls",
				"gopls",
				"yamlls",
				"jsonls",
				"ts_ls",
				"tailwindcss",
			},
			-- roslyn.nvim runs C#'s server as "roslyn" (lazy/csharp.lua). Enabling lspconfig's roslyn_ls for
			-- the same Mason package, or a leftover csharp-ls install, would attach a second C# client.
			automatic_enable = {
				exclude = { "roslyn_ls", "csharp_ls" },
			},
		})
		mason_tool_installer.setup({
			-- debug adapters (delve, netcoredbg, ...) are installed by mason-nvim-dap; listing them here
			-- too races its install on a fresh machine ("Package is already installing").
			ensure_installed = {
				"prettier",
				"stylua",
				"eslint_d",
				"goimports",
				"tree-sitter-cli", -- nvim-treesitter compiles parsers with it (treesitter.lua)
				-- Microsoft's package from nuget.org, pinned because Mason's registry lags behind and its default is
				-- older than roslyn.nvim supports. The plugin update workflow doesn't bump this; do it by hand.
				-- Mason installs it with `dotnet tool`, so skip it where there's no .NET (e.g. WSL without C#)
				-- rather than report a failed install on every start.
				{
					"roslyn-language-server",
					version = "5.13.0-1.26514.10",
					condition = function()
						return vim.fn.executable("dotnet") == 1
					end,
				},
			},
		})
	end,
}
