return {
	"rmagatti/auto-session",
	event = "VimEnter",
	dependencies = { "nvim-telescope/telescope.nvim" },
	keys = {
		{
			"<leader>wr",
			"<cmd>Telescope session-lens search_session<CR>",
			desc = "[W]orkspace [R]estore",
		},
		{
			"<leader>ws",
			"<cmd>AutoSession save<CR>", -- THIS IS THE CORRECT COMMAND
			desc = "[W]orkspace [S]ave",
		},
	},
	opts = {
		log_level = "error",
		auto_restore_enabled = false,
		auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop" },
		pre_save_cmds = { "NvimTreeClose" },
	},
}
