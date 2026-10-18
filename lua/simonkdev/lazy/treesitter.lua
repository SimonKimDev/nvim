-- nvim-treesitter's main branch only installs parsers and queries. Highlighting is Neovim's own and has to be
-- started per buffer (FileType autocmd below). Compiling parsers needs the tree-sitter CLI and a C compiler;
-- Mason installs the CLI (lsp/mason.lua).
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- doesn't support lazy-loading
		build = ":TSUpdate",
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
				"gomod",
				"gosum",
				"gowork",
				"rust",
				"toml",
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
		},
		config = function(_, opts)
			local ts = require("nvim-treesitter")

			-- A no-op for installed parsers. On a fresh machine the CLI shows up once Mason has installed it.
			local function install()
				if vim.fn.executable("tree-sitter") == 1 then
					ts.install(opts.ensure_installed)
				end
			end
			install()
			vim.api.nvim_create_autocmd("User", { pattern = "MasonToolsUpdateCompleted", callback = install })

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("simonkdev_treesitter", { clear = true }),
				callback = function(args)
					-- Fails when there's no parser for the filetype; those keep regex highlighting.
					if pcall(vim.treesitter.start, args.buf) then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- Neovim 0.12 selects treesitter nodes with `an` (outward) and `in` (inward) in visual mode.
			vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Select treesitter node" })
			vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Expand selection" })
			vim.keymap.set("x", "<bs>", "in", { remap = true, desc = "Shrink selection" })
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
}
