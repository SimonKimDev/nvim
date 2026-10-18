-- neotest-vitest assumes Unix paths. On Windows it runs node_modules/.bin/vitest, a shell script Windows can't
-- start, mixes C:/ and C:\ paths, and can't find the project's config: tests aren't found when Neovim was started
-- above the project (e.g. at a monorepo root), tests that use Vitest globals fail, and every result reads as
-- failed (marilari88/neotest-vitest#90; the unmerged fix #74 covers only the last part). These patches use
-- Windows paths throughout; drop them once upstream handles Windows.
local function vitest_adapter()
	local adapter = require("neotest-vitest")
	if vim.fn.has("win32") == 0 then
		return adapter({})
	end

	local function native(path)
		return (path:gsub("^%a:", string.upper):gsub("/", "\\"))
	end

	local root = adapter.root
	adapter.root = function(path)
		local dir = root(path)
		return dir and native(dir)
	end

	local util = require("neotest-vitest.util")
	local to_results = util.parsed_json_to_results
	util.parsed_json_to_results = function(data, ...)
		for _, file in pairs(data.testResults or {}) do
			file.name = native(file.name)
		end
		return to_results(data, ...)
	end

	return adapter({
		vitestCommand = function(path)
			for dir in vim.fs.parents(path) do
				local bin = vim.fs.joinpath(dir, "node_modules", ".bin", "vitest.cmd")
				if vim.uv.fs_stat(bin) then
					return bin
				end
			end
			return "vitest"
		end,
		-- It finds the project with a {vite,vitest}.config.* glob, and Windows glob has no braces. Run from the
		-- package directory instead, where Vitest picks up vite.config.ts (globals etc.) itself.
		cwd = function(path)
			return vim.fs.root(path, "package.json")
		end,
	})
end

-- neotest parses test files in a child Neovim started with -u NONE, which never loads nvim-treesitter's filetype
-- aliases (typescriptreact -> tsx), so .tsx test files show no tests (nvim-neotest/neotest#630, #631). Adding
-- nvim-treesitter to the child's runtimepath fixes it: neotest's add_paths_to_rtp sources plugin/filetypes.lua.
local function load_treesitter_aliases_in_subprocess()
	local subprocess = require("neotest.lib").subprocess
	local init = subprocess.init
	subprocess.init = function(...)
		init(...)
		local treesitter = require("lazy.core.config").plugins["nvim-treesitter"]
		if subprocess.enabled() and treesitter then
			subprocess.add_paths_to_rtp({ treesitter.dir })
		end
	end
end

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"Nsidorenco/neotest-vstest",
			{ "fredrikaverpil/neotest-golang", version = "^2" },
			"marilari88/neotest-vitest",
		},
		config = function()
			load_treesitter_aliases_in_subprocess()
			require("neotest").setup({
				adapters = {
					require("neotest-vstest")({
						-- mason-nvim-dap registers netcoredbg under the "coreclr" adapter name
						dap_settings = { type = "coreclr" },
					}),
					require("neotest-golang")(), -- debugs tests through nvim-dap-go
					require("rustaceanvim.neotest"), -- debugs tests through codelldb
					vitest_adapter(),
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
