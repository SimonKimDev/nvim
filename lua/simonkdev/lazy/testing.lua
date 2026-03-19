return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "Nsidorenco/neotest-vstest",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-vstest")({
                        dotnet_cmd = { "C:\\Program Files\\dotnet\\dotnet.exe" },
                        test_project_pattern = "*Tests.csproj",
                    }),
                },
                status = { virtual_text = true },
                output = {
                    open_on_run = true,
                },
                summary = {
                    mapping = {
                        run = "<CR>",
                        stop = "s",
                        output = "o",
                        ["[d"] = "prev_failed",
                        ["]d"] = "next_failed",
                    },
                },
            })
        end,
        keys = {
            { "<leader>TA", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "[T]est: Run [A]ll Files" },
            { "<leader>Tr", function() require("neotest").run.run() end, desc = "[T]est: [R]un Nearest" },
            { "<leader>TF", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "[T]est: Run Current [F]ile" },
            { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "[T]est: Toggle [S]ummary" },
            { "<leader>To", function() require("neotest").output.open({ enter = true }) end, desc = "[T]est: Show [O]utput" },
            { "<leader>TS", function() require("neotest").run.stop() end, desc = "[T]est: [S]top" },
            { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "[T]est: [D]ebug Nearest" },
        },
    },
}
