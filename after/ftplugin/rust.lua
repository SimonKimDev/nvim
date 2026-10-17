-- :make (<leader>b) runs `cargo build` and loads rustc's errors into the quickfix list
vim.cmd.compiler("cargo")
vim.opt_local.makeprg = "cargo build"

local function map(lhs, subcommand, desc)
	vim.keymap.set("n", lhs, function()
		vim.cmd.RustLsp(subcommand)
	end, { buffer = true, desc = desc })
end
map("<leader>rr", "runnables", "Rust: Runnables")
map("<leader>rd", "debuggables", "Rust: Debuggables")
map("<leader>re", "explainError", "Rust: Explain Error")
