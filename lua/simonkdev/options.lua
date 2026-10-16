vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, it assumes case-insensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start" -- allow backspaces on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical windows to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- scrolloff
opt.scrolloff = 8

-- persistent undo history across sessions
opt.undofile = true

if vim.fn.has("win32") == 1 then
	-- :h shell-powershell; stderr is merged and the exit code propagated so :make and v:shell_error work
	local pwsh = vim.fn.executable("pwsh") == 1
	opt.shell = pwsh and "pwsh" or "powershell"
	opt.shellcmdflag = "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command "
		.. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
		.. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
		.. "$PSStyle.OutputRendering='plaintext';"
		.. "Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
	opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
	-- pwsh's Tee-Object writes UTF-8 and, unlike Neovim's bundled tee.exe, keeps the build's $LastExitCode
	opt.shellpipe = '2>&1 | %%{ "$_" } | ' .. (pwsh and "Tee-Object" or "tee") .. " %s; exit $LastExitCode"
	opt.shellquote = ""
	opt.shellxquote = ""
end
