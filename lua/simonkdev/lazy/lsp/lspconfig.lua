return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp-nvim-lsp")
        local on_attach = function(client, bufnr)

        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

          -- Each keymap now has a unique description for which-key
          map("n", "gR", "<cmd>Telescope lsp_references<CR>", "Go to References")
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Go to Definition")
          map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Go to Implementation")
          map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Go to Type Definition")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Document Diagnostics")
          map("n", "<leader>d", vim.diagnostic.open_float, "Line Diagnostics")
          map("n", "<leader>dD", "<cmd>Telescope diagnostics<CR>", "Workspace Diagnostics")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
          map("n", "<leader>rs", ":LspRestart<CR>", "Restart LSP")
        end
		
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.HINT] = "󰠠",
					[vim.diagnostic.severity.INFO] = "",
				},
			},
		})

		local servers_to_install = { "lua_ls", "csharp_ls" }
		mason_lspconfig.setup({
			ensure_installed = servers_to_install,
		})

		-- Define server-specific settings
		local server_configs = {
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			},
		}

		-- Loop through servers and set them up
		for _, server_name in ipairs(servers_to_install) do
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- FIX 2: Add C#-specific capability
			if server_name == "csharp_ls" then
				capabilities.offsetEncoding = { "utf-16" }
			end

			local opts = {
				on_attach = on_attach,
				capabilities = capabilities,
			}

			local server_config = server_configs[server_name]
			if server_config then
				opts = vim.tbl_deep_extend("force", opts, server_config)
			end

			-- FIX 3: Use the new API for setting up servers
			vim.lsp.config(server_name, opts)
		end
	end,
}
