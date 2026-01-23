vim.keymap.set("n", "<leader>le", ":edit .env<cr>", { desc = "Open .env file" })
vim.keymap.set("n", "<leader>ll", ":edit storage/logs/laravel.log<cr>", { desc = "Open Laravel log file" })
vim.keymap.set("n", "<leader>lb", ":edit storage/logs/browser.log<cr>", { desc = "Open browser log file" })
vim.keymap.set("n", "<leader>lx", ":!echo '' > storage/logs/laravel.log<cr>", { desc = "Clear Laravel log file" })
