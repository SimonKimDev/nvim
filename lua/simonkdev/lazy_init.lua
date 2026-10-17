local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- lazy.nvim puts stdpath("data")/site on the runtimepath, but Neovim drops it if it doesn't exist yet.
-- nvim-treesitter installs parsers there, so on a fresh machine they'd only load after a restart.
vim.fn.mkdir(vim.fn.stdpath("data") .. "/site", "p")

require("lazy").setup({
	{ import = "simonkdev.lazy" },
	{ import = "simonkdev.lazy.lsp" },
	{ import = "simonkdev.lazy.debugger" },
}, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})
