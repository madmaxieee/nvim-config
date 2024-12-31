-- common typos
vim.api.nvim_create_user_command("Q", "q<bang>", { bang = true })
vim.api.nvim_create_user_command("Qa", "qa<bang>", { bang = true })
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("Wqa", "wqa", {})
vim.api.nvim_create_user_command("Vs", "vs", {})

-- save without auto format
vim.api.nvim_create_user_command("WW", "noa w", {})

vim.api.nvim_create_user_command("SourceThis", "source %", {})
