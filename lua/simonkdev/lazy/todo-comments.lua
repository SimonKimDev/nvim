return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local todo_comments = require("todo-comments")

		-- set keymaps
		vim.keymap.set("n", "]t", function()
			todo_comments.jump_next()
		end, { desc = "next todo comment" })

		vim.keymap.set("n", "[t", function()
			todo_comments.jump_prev()
		end, { desc = "prev todo comment" })

		todo_comments.setup()
	end,
}
