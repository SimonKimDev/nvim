return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	config = function()
		local dap = require("dap")

		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug Continue / Start" })
		vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug Step Into" })
		vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug Step Over" })
		vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug Step Out" })
		vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug REPL" })
		vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
	end,
}
