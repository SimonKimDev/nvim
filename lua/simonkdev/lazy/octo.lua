-- GitHub issues, PRs and reviews in Neovim. Runs everything through the GitHub CLI, so `gh auth login` first.
return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		picker = "telescope",
		enable_builtin = true, -- a bare :Octo opens a picker of its commands
	},
	keys = {
		{ "<leader>oo", "<cmd>Octo<cr>", desc = "Octo: commands" },
		{ "<leader>op", "<cmd>Octo pr list<cr>", desc = "Octo: list pull requests" },
		{ "<leader>oi", "<cmd>Octo issue list<cr>", desc = "Octo: list issues" },
		{ "<leader>on", "<cmd>Octo notification list<cr>", desc = "Octo: notifications" },
	},
}
