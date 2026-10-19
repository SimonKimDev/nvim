return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = { "williamboman/mason.nvim" },
	opts = {
		ensure_installed = {
			"delve",
			"chrome-debug-adapter",
			"js-debug-adapter",
			"coreclr",
			"codelldb", -- Rust, through rustaceanvim
		},
		handlers = {
			-- Replace mason-nvim-dap's "pick any DLL" C# configuration with build-then-debug (simonkdev/dotnet.lua).
			coreclr = function(config)
				local dotnet = require("simonkdev.dotnet")
				config.adapters = vim.tbl_extend("force", config.adapters, { enrich_config = dotnet.enrich_config })
				config.configurations = { dotnet.configuration }
				require("mason-nvim-dap").default_setup(config)
			end,
			-- rustaceanvim registers codelldb and Rust's debug configurations itself (lazy/rust.lua)
			codelldb = function() end,
		},
	},
	event = "VeryLazy",
}
