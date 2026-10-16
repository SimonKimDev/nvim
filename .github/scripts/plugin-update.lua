-- Update every plugin, rewrite lazy-lock.json and write a Markdown summary for the update PR.
-- Run by .github/workflows/plugin-update.yml, after the setup-nvim action isolated Neovim's directories:
--   nvim --headless "+luafile .github/scripts/plugin-update.lua"
-- Env: OLD_LOCKFILE is a copy of lazy-lock.json from before the update; the summary goes to SUMMARY_FILE.

local function read_json(path)
	return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
end

local function short(sha)
	return "`" .. sha:sub(1, 7) .. "`"
end

local function update()
	local Config = require("lazy.core.config")
	local Plugin = require("lazy.core.plugin")

	require("lazy").update({ wait = true, show = false })

	local old, new = read_json(vim.env.OLD_LOCKFILE), read_json(Config.options.lockfile)
	local names = vim.tbl_keys(vim.tbl_extend("force", {}, old, new))
	table.sort(names)

	local rows = {}
	for _, name in ipairs(names) do
		local from, to = old[name] and old[name].commit, new[name] and new[name].commit
		if from ~= to then
			local plugin = Config.plugins[name]
			local repo = plugin and plugin.url and (plugin.url:gsub("%.git$", ""))
			local change
			if not from then
				change = "added at " .. short(to)
			elseif not to then
				change = "removed"
			elseif repo and repo:match("^https://github%.com/") then
				change = ("[%s...%s](%s/compare/%s...%s)"):format(short(from), short(to), repo, from, to)
			else
				change = short(from) .. "..." .. short(to)
			end
			table.insert(rows, ("| %s | %s |"):format(name, change))
		end
	end

	local failed = {}
	for name, plugin in pairs(Config.plugins) do
		if Plugin.has_errors(plugin) then
			table.insert(failed, name)
		end
	end
	table.sort(failed)

	local run = ("%s/%s/actions/runs/%s"):format(
		vim.env.GITHUB_SERVER_URL or "https://github.com",
		vim.env.GITHUB_REPOSITORY or "",
		vim.env.GITHUB_RUN_ID or ""
	)
	local lines = {
		("Weekly `:Lazy update` from the [plugin update workflow](%s)."):format(run),
		"CI installs these exact commits into empty directories and runs the smoke test; merge if it's green.",
		"",
		"| Plugin | Change |",
		"| --- | --- |",
	}
	vim.list_extend(lines, rows)
	if #failed > 0 then
		vim.list_extend(lines, {
			"",
			"> [!WARNING]",
			"> These plugins reported errors while updating (see the workflow log): " .. table.concat(failed, ", "),
		})
	end
	vim.fn.writefile(lines, vim.env.SUMMARY_FILE)

	io.stdout:write(("\n%d plugin(s) changed, %d with errors\n"):format(#rows, #failed))
end

local ok, err = xpcall(update, debug.traceback)
if not ok then
	io.stdout:write("\nplugin update failed:\n" .. err .. "\n")
end
vim.cmd(ok and "qa!" or "cquit 1")
