return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"Nsidorenco/neotest-vstest",
			-- v2 requires nvim-treesitter's main branch; this config is still on master (see treesitter.lua).
			{ "fredrikaverpil/neotest-golang", version = "^1" },
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-vstest")({
						-- mason-nvim-dap registers netcoredbg under the "coreclr" adapter name
						dap_settings = { type = "coreclr" },
					}),
					require("neotest-golang")(), -- debugs tests through nvim-dap-go
				},
				status = { virtual_text = true },
				output = {
					open_on_run = true,
				},
				summary = {
					mappings = {
						run = "<CR>",
						expand = { "<Tab>", "<2-LeftMouse>" },
						stop = "s",
						output = "o",
						prev_failed = "[d",
						next_failed = "]d",
					},
				},
			})
		end,
		keys = {
			{
				"<leader>TA",
				function()
					require("neotest").run.run(vim.fn.getcwd())
				end,
				desc = "[T]est: Run [A]ll Files",
			},
			{
				"<leader>Tr",
				function()
					require("neotest").run.run()
				end,
				desc = "[T]est: [R]un Nearest",
			},
			{
				"<leader>TF",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "[T]est: Run Current [F]ile",
			},
			{
				"<leader>Ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "[T]est: Toggle [S]ummary",
			},
			{
				"<leader>To",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "[T]est: Show [O]utput",
			},
			{
				"<leader>TS",
				function()
					require("neotest").run.stop()
				end,
				desc = "[T]est: [S]top",
			},
			{
				"<leader>Td",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "[T]est: [D]ebug Nearest",
			},
		},
	},
}
