-- Headless smoke test: boot the config, exercise every plugin, fail on any reported error.
-- Must run via --cmd so the error hooks are installed before init.lua:
--   nvim --headless --cmd "luafile tests/smoke.lua"

-- Roslyn runs as a daemon that outlives Neovim by 15 minutes and inherits its output handles, so a redirected run
-- (CI, scripts) would hang until it exits. Make it exit with its last client.
vim.env.ROSLYN_LANGUAGE_SERVER_DAEMON_KEEPALIVE = "0"

-- Mason package downloads depend on the network and upstream registries (e.g. npm ETARGET), not on this config.
local ignored = {
	"^[%w_.%-]+: failed to install$", -- mason-tool-installer
	"^%[mason%-lspconfig%.nvim%] failed to install ",
}

local errors, seen = {}, {}
local function record(msg)
	msg = vim.trim(tostring(msg))
	for _, pattern in ipairs(ignored) do
		if msg:match(pattern) then
			return
		end
	end
	if msg ~= "" and not seen[msg] then
		seen[msg] = true
		table.insert(errors, msg)
	end
end

local notify = vim.notify
vim.notify = function(msg, level, opts)
	if level == vim.log.levels.ERROR then
		record(msg)
	end
	return notify(msg, level, opts)
end

local echo = vim.api.nvim_echo
vim.api.nvim_echo = function(chunks, history, opts)
	if opts and opts.err then
		record(table.concat(
			vim.tbl_map(function(c)
				return c[1]
			end, chunks),
			""
		))
	end
	return echo(chunks, history, opts)
end

local err_writeln = vim.api.nvim_err_writeln
vim.api.nvim_err_writeln = function(msg)
	record(msg)
	return err_writeln(msg)
end

local function finish(code)
	-- Don't let auto-session save the test buffers over a real session when run locally.
	local auto_session = package.loaded["auto-session"]
	if auto_session then
		pcall(auto_session.disable_auto_save)
	end

	io.stdout:write("\n--- smoke report ---\n") -- CI splits the log here
	io.stdout:write(table.concat(errors, "\n\n") .. (#errors > 0 and "\n\n" or ""))
	io.stdout:write(code == 0 and "smoke: OK\n" or ("smoke: FAILED (%d error(s))\n"):format(#errors))
	vim.cmd(code == 0 and "qa!" or ("cquit " .. code))
end

-- Watchdog in case something blocks (first run also installs every plugin).
vim.defer_fn(function()
	record("smoke: timed out")
	finish(2)
end, 10 * 60 * 1000)

local function step(name, fn)
	local ok, err = xpcall(fn, debug.traceback)
	if not ok then
		record(("[%s] %s"):format(name, err))
	end
	vim.wait(1000) -- let scheduled callbacks and autocmds run
end

-- Vim errors (E123:, errors thrown in init.lua/autocmds/callbacks) only show up in message history.
local function scan_messages()
	local lines = vim.split(vim.api.nvim_exec2("messages", { output = true }).output, "\n")
	local i = 1
	while i <= #lines do
		if lines[i]:match("^E%d+:") or lines[i]:match("^Error ") then
			local block = { lines[i] }
			while lines[i + 1] and (lines[i + 1]:match("^%s") or lines[i + 1] == "stack traceback:") do
				i = i + 1
				table.insert(block, lines[i])
			end
			record(table.concat(block, "\n"))
		end
		i = i + 1
	end
end

local function run()
	scan_messages() -- startup errors first; they usually cause the later failures

	step("open lua buffer", function()
		vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
	end)

	step("open cs buffer", function()
		local cs = vim.fn.tempname() .. ".cs"
		vim.fn.writefile({ "namespace Smoke { class C { } }" }, cs)
		vim.cmd.edit(cs)
	end)

	-- lazy.nvim fires VeryLazy on UIEnter, which never happens headless.
	step("VeryLazy", function()
		vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
	end)

	step("load all plugins", function()
		local plugins = require("lazy.core.config").plugins
		local names = vim.tbl_keys(plugins)
		table.sort(names)
		require("lazy").load({ plugins = names })
		for _, name in ipairs(names) do
			if not plugins[name]._.loaded then
				record("plugin did not load: " .. name)
			end
		end
	end)
	vim.wait(2000)
	scan_messages()

	-- Parsers install in the background at startup; wait for them so the checks below can use them.
	step("treesitter parsers", function()
		if vim.fn.executable("tree-sitter") == 0 then
			record("tree-sitter CLI isn't on PATH, so nvim-treesitter can't compile parsers")
			return
		end
		local spec = require("lazy.core.config").plugins["nvim-treesitter"]
		local wanted = require("lazy.core.plugin").values(spec, "opts", false).ensure_installed
		-- install() can return before the installs that started at startup finish, so poll for the parsers.
		require("nvim-treesitter").install(wanted)
		local function missing()
			return vim.tbl_filter(function(lang)
				local ok, loaded = pcall(vim.treesitter.language.add, lang)
				return not (ok and loaded)
			end, wanted)
		end
		vim.wait(8 * 60 * 1000, function()
			return #missing() == 0
		end, 1000)
		for _, lang in ipairs(missing()) do
			record("treesitter parser didn't install: " .. lang)
		end
	end)
	scan_messages()

	-- Wiring mistakes that never raise an error (e.g. a misspelled server name is silently skipped).
	step("config checks", function()
		local function check(ok, msg)
			if not ok then
				record("check: " .. msg)
			end
		end

		check(vim.o.undofile, "undofile is off")
		check(vim.fn.maparg("<leader>ih", "n") ~= "", "<leader>ih (inlay hints) is not mapped")

		-- A second mason-lspconfig setup() call replaces this list, so check it survived startup.
		local servers = require("mason-lspconfig.settings").current.ensure_installed
		for _, name in ipairs({ "gopls", "ts_ls", "lua_ls" }) do
			check(vim.tbl_contains(servers, name), name .. " is missing from mason-lspconfig ensure_installed")
		end
		-- rustaceanvim runs rust-analyzer; a second client from lspconfig would duplicate every result.
		check(not vim.lsp.is_enabled("rust_analyzer"), "rust_analyzer is enabled alongside rustaceanvim")
		-- Same for C#: roslyn.nvim's "roslyn" client only. lspconfig's roslyn_ls would start for the same
		-- Mason package once it's installed, so check it's excluded rather than whether it's enabled yet.
		check(vim.lsp.is_enabled("roslyn"), "roslyn.nvim didn't enable the roslyn client")
		local exclude = vim.tbl_get(require("mason-lspconfig.settings").current, "automatic_enable", "exclude") or {}
		for _, name in ipairs({ "roslyn_ls", "csharp_ls" }) do
			check(vim.list_contains(exclude, name), name .. " isn't excluded from mason-lspconfig automatic_enable")
		end
		for _, name in ipairs(servers) do
			local config = vim.lsp.config[name]
			check(config and config.cmd ~= nil, "no LSP config named " .. name)
		end

		-- Scratch buffers get FileType without BufEnter, so nvim-lint doesn't try to run eslint_d.
		local conform = require("conform")
		local expected = {
			go = "goimports",
			typescriptreact = "prettier",
			lua = "stylua",
			rust = "trim_whitespace", -- after rust-analyzer's rustfmt
			text = "trim_whitespace",
		}
		for ft, formatter in pairs(expected) do
			local buf = vim.api.nvim_create_buf(true, true)
			vim.bo[buf].filetype = ft
			local formatters = conform.list_formatters_for_buffer(buf)
			check(vim.tbl_contains(formatters, formatter), ("%s buffers don't format with %s"):format(ft, formatter))
			if ft ~= "text" then
				check(vim.treesitter.highlighter.active[buf] ~= nil, ft .. " buffers don't get treesitter highlighting")
			end
			if ft == "typescriptreact" then
				check(vim.bo[buf].shiftwidth == 2, "typescriptreact shiftwidth is " .. vim.bo[buf].shiftwidth)
			end
			vim.api.nvim_buf_delete(buf, { force = true })
		end

		-- Every language has a test adapter; a missing one leaves <leader>T… silently finding no tests.
		local adapters = vim.tbl_map(function(a)
			return a.name
		end, require("neotest.config").adapters)
		for _, name in ipairs({ "neotest-vstest", "neotest-golang", "rustaceanvim", "neotest-vitest" }) do
			check(vim.list_contains(adapters, name), "neotest has no " .. name .. " adapter")
		end

		-- Files without a formatter (and C#, after Roslyn) are trimmed on save; patches are left alone.
		check(vim.tbl_contains(conform.formatters_by_ft.cs, "trim_whitespace"), "cs buffers aren't trimmed")
		local input = { " a ", "", "" }
		for ft, want in pairs({ text = { " a" }, diff = input }) do
			local buf = vim.api.nvim_create_buf(true, true)
			vim.bo[buf].filetype = ft
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, input)
			conform.format({ bufnr = buf, async = false })
			local got = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			check(vim.deep_equal(got, want), ("%s buffer formatted to %s"):format(ft, vim.inspect(got)))
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end)
	scan_messages()

	finish(#errors == 0 and 0 or 1)
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.schedule(run) -- after other VimEnter handlers (alpha, auto-session)
	end,
})
