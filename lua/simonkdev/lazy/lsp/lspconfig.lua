return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- LspAttach covers every server mason-lspconfig auto-enables, not just the ones listed below.
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("simonkdev_lsp_attach", { clear = true }),
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				-- copilot.lua runs as an LSP client; don't shadow builtins like gt/gi in copilot-only buffers.
				if client and client.name == "copilot" then
					return
				end

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
				end

				map("n", "gR", "<cmd>Telescope lsp_references<CR>", "Go to References")
				map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
				map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Go to Definition")
				map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Go to Implementation")
				map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Go to Type Definition")
				map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
				map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
				map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Document Diagnostics")
				map("n", "<leader>dd", vim.diagnostic.open_float, "Line Diagnostics")
				map("n", "<leader>dD", "<cmd>Telescope diagnostics<CR>", "Workspace Diagnostics")
				map("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, "Previous Diagnostic")
				map("n", "]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, "Next Diagnostic")
				map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
				map("n", "<leader>rs", ":LspRestart<CR>", "Restart LSP")
			end,
		})

		vim.diagnostic.config({
			virtual_text = true, -- off by default since Neovim 0.11
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.HINT] = "󰠠",
					[vim.diagnostic.severity.INFO] = "",
				},
			},
		})

		-- Servers are installed and enabled by mason-lspconfig (lsp/mason.lua); this only configures them.
		vim.lsp.config("*", {
			capabilities = cmp_nvim_lsp.default_capabilities(),
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
				},
			},
		})

		vim.lsp.config("csharp_ls", {
			capabilities = { offsetEncoding = { "utf-16" } },
		})

		-- Inlay hints stay hidden until toggled with <leader>ih; these settings make the servers send them.
		vim.lsp.config("gopls", {
			settings = {
				gopls = {
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		})

		local ts_inlay_hints = {
			includeInlayParameterNameHints = "literals",
			includeInlayFunctionParameterTypeHints = true,
			includeInlayVariableTypeHints = true,
			includeInlayPropertyDeclarationTypeHints = true,
			includeInlayFunctionLikeReturnTypeHints = true,
			includeInlayEnumMemberValueHints = true,
		}
		vim.lsp.config("ts_ls", {
			settings = {
				typescript = { inlayHints = ts_inlay_hints },
				javascript = { inlayHints = ts_inlay_hints },
			},
		})
	end,
}
