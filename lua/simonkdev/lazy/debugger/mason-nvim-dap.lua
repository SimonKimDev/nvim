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
			-- rustaceanvim registers codelldb and Rust's debug configurations itself (lazy/rust.lua)
			codelldb = function() end,
		},
	},
	event = "VeryLazy",
}
