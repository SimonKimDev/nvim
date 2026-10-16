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

		mason_lspconfig.setup({
			ensure_installed = {
				"html",
				"lua_ls",
				"cssls",
				"csharp_ls",
				"gopls",
				"yamlls",
				"jsonls",
			},
		})
		mason_tool_installer.setup({
			-- debug adapters (delve, netcoredbg, ...) are installed by mason-nvim-dap; listing them here
			-- too races its install on a fresh machine ("Package is already installing").
			ensure_installed = {
				"prettier",
				"stylua",
				"eslint_d",
			},
		})
	end,
}
