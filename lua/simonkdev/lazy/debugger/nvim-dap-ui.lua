return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup()

		dap.listeners.after.event_initialized["dapui_autoopen"] = function()
			dapui.open()
		end
		for _, e in ipairs({ "event_terminated", "event_exited" }) do
			dap.listeners.before[e]["dapui_autoclose"] = function()
				dapui.close()
			end
		end
	end,
}
