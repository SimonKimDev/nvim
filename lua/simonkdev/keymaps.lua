vim.g.mapleader = " "

vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- runs 'makeprg'; C# buffers use :compiler dotnet (after/ftplugin/cs.lua)
vim.keymap.set("n", "<leader>b", "<cmd>make!<CR>", { desc = "[B]uild Project" })

-- View Erros on Telescope
vim.keymap.set("n", "<leader>qf", "<cmd>Telescope quickfix<CR>", { desc = "Open [Q]uick[f]ix in Telescope" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next Quickfix Item" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous Quickfix Item" })
