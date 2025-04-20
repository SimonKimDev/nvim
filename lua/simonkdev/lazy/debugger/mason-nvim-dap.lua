return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = { "williamboman/mason.nvim" },
	opts = {
		ensure_installed = { "delve" },
		handlers = {},
	},
	event = "VeryLazy",
}
