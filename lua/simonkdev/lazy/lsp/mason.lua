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
				"csharp_ls",
				"gopls",
				"yamlls",
				"jsonls",
				"ts_ls",
				"tailwindcss",
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
			},
		})
	end,
}
