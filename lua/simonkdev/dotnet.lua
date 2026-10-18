-- Build-then-debug for .NET with netcoredbg (mason-nvim-dap's "coreclr" adapter, lazy/debugger/mason-nvim-dap.lua).
-- The "Build and debug a project" configuration lists the solution's runnable projects, builds the one you pick,
-- and launches the DLL MSBuild reports for it, so there's no hunting through bin\Debug.
local M = {}

local last_project ---@type string?

-- Same as :compiler dotnet, so build errors land in the quickfix list like <leader>b.
local errorformat = "%E%f(%l\\,%c): %trror %m,%W%f(%l\\,%c): %tarning %m,%-G%.%#"

---Runs a command without blocking the UI. Call from inside a coroutine.
---@return vim.SystemCompleted
local function run(cmd)
	local co = coroutine.running()
	vim.system(cmd, { text = true }, function(result)
		vim.schedule(function()
			coroutine.resume(co, result)
		end)
	end)
	return coroutine.yield()
end

---@return string?
local function pick(items, prompt, format_item)
	local co = coroutine.running()
	vim.ui.select(items, { prompt = prompt, format_item = format_item }, function(choice)
		vim.schedule(function()
			coroutine.resume(co, choice)
		end)
	end)
	return coroutine.yield()
end

---The solution or project roslyn.nvim is using, else the nearest solution or project above the buffer.
---@return string?
local function target()
	local selected = vim.g.roslyn_nvim_selected_solution
	if selected and vim.uv.fs_stat(selected) then
		return selected
	end
	return vim.fs.find(function(name)
		return name:match("%.slnx?$") ~= nil or name:match("%.csproj$") ~= nil
	end, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1]
end

---@return string[]
local function projects(sln_or_proj)
	if sln_or_proj:match("%.csproj$") then
		return { sln_or_proj }
	end
	local result = run({ "dotnet", "sln", sln_or_proj, "list" })
	local found = {}
	for line in result.stdout:gmatch("[^\r\n]+") do
		line = vim.trim(line)
		if line:match("%.csproj$") then
			table.insert(found, vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(sln_or_proj), line)))
		end
	end
	return found
end

-- A quick read of the project file. OutputType set in Directory.Build.props is missed, hence the fallback below.
local function runnable(project)
	local ok, lines = pcall(vim.fn.readfile, project)
	local text = ok and table.concat(lines, "\n") or ""
	local output_type = (text:match("<OutputType>%s*(%a+)%s*</OutputType>") or ""):lower()
	return output_type == "exe"
		or output_type == "winexe"
		or text:match('Sdk="Microsoft%.NET%.Sdk%.Web"') ~= nil
		or text:match('Sdk="Microsoft%.NET%.Sdk%.Worker"') ~= nil
end

---@return table<string, string>?
local function properties(project, framework)
	local cmd = { "dotnet", "msbuild", project, "-nologo", "-p:Configuration=Debug" }
	vim.list_extend(cmd, { "-getProperty:TargetPath", "-getProperty:TargetFrameworks" })
	if framework then
		table.insert(cmd, "-p:TargetFramework=" .. framework)
	end
	local result = run(cmd)
	local ok, decoded = pcall(vim.json.decode, result.stdout)
	if result.code ~= 0 or not ok then
		vim.notify("dotnet msbuild failed:\n" .. result.stdout .. result.stderr, vim.log.levels.ERROR)
		return nil
	end
	return decoded.Properties
end

---netcoredbg only debugs .NET (Core), so skip .NET Framework targets like net472 and take the newest one.
---@return string?
local function pick_framework(frameworks)
	local best, best_version
	for framework in frameworks:gmatch("[^;%s]+") do
		local major, minor = framework:match("^net(%d+)%.(%d+)")
		if not major then
			major, minor = framework:match("^netcoreapp(%d+)%.(%d+)")
		end
		local version = major and tonumber(major) * 100 + tonumber(minor)
		if version and (not best_version or version > best_version) then
			best, best_version = framework, version
		end
	end
	return best
end

---@return {program: string, cwd: string}?
local function pick_and_build()
	local sln_or_proj = target()
	if not sln_or_proj then
		vim.notify("No .sln, .slnx or .csproj found above this file", vim.log.levels.ERROR)
		return nil
	end

	local all = projects(sln_or_proj)
	local candidates = vim.tbl_filter(runnable, all)
	if #candidates == 0 then
		candidates = all
	end
	if last_project and vim.list_contains(candidates, last_project) then
		candidates = vim.list_extend(
			{ last_project },
			vim.tbl_filter(function(p)
				return p ~= last_project
			end, candidates)
		)
	end

	local project = #candidates == 1 and candidates[1]
		or pick(candidates, "Debug which project?", function(p)
			return vim.fn.fnamemodify(p, ":t:r")
		end)
	if not project then
		return nil
	end
	last_project = project
	local name = vim.fn.fnamemodify(project, ":t:r")

	local props = properties(project)
	if not props then
		return nil
	end
	local framework
	if props.TargetPath == "" then
		framework = pick_framework(props.TargetFrameworks)
		if not framework then
			vim.notify(name .. " has no .NET (Core) target framework for netcoredbg", vim.log.levels.ERROR)
			return nil
		end
		props = properties(project, framework)
		if not props then
			return nil
		end
	end

	vim.notify(("Building %s%s..."):format(name, framework and (" (" .. framework .. ")") or ""))
	local build = { "dotnet", "build", project, "-nologo", "-c", "Debug", "-consoleloggerparameters:NoSummary" }
	if framework then
		vim.list_extend(build, { "-f", framework })
	end
	local result = run(build)
	if result.code ~= 0 then
		vim.fn.setqflist({}, " ", {
			title = "dotnet build " .. name,
			lines = vim.split(result.stdout .. result.stderr, "\r?\n"),
			efm = errorformat,
		})
		vim.cmd.copen()
		vim.notify("Build failed: " .. name, vim.log.levels.ERROR)
		return nil
	end

	-- `dotnet run` starts in the project directory, so appsettings.json and relative paths resolve the same way.
	return { program = props.TargetPath, cwd = vim.fs.dirname(project) }
end

M.configuration = {
	type = "coreclr",
	name = "Build and debug a project",
	request = "launch",
	build_and_pick = true, -- handled by enrich_config below
}

---Adapter hook: nvim-dap calls it with the resolved configuration before launching.
---Other coreclr configurations (e.g. neotest's test debugging) pass through untouched.
function M.enrich_config(config, on_config)
	if not config.build_and_pick then
		return on_config(config)
	end
	coroutine.wrap(function()
		local launch = pick_and_build()
		if launch then
			local resolved = vim.tbl_extend("force", config, launch)
			resolved.build_and_pick = nil
			on_config(resolved)
		end
	end)()
end

return M
