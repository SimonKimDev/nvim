local group = vim.api.nvim_create_augroup("simonkdev", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	desc = "Highlight yanked text",
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Web tooling (prettier, eslint) expects 2-space indents; a project .editorconfig still wins.
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"jsonc",
		"css",
		"scss",
		"html",
		"yaml",
	},
	callback = function(ev)
		vim.bo[ev.buf].tabstop = 2
		vim.bo[ev.buf].softtabstop = 2
		vim.bo[ev.buf].shiftwidth = 2
	end,
})
