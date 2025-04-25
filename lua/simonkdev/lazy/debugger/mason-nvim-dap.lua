return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = { "williamboman/mason.nvim" },
	opts = {
		ensure_installed = {
			"delve",
			"chrome-debug-adapter",
			"js-debug-adapter",
		},
		handlers = {},
	},
	event = "VeryLazy",
}
