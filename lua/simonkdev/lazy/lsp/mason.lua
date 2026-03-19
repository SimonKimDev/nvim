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

		local path_sep = vim.loop.os_path_sep or (vim.fn.has("win32") and ";" or ":")
		vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. path_sep .. vim.env.PATH

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
			ensure_installed = {
				"prettier",
				"stylua",
				"eslint_d",
				"delve",
			},
		})
	end,
}
