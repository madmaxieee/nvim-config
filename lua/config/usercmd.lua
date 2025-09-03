-- common typos
vim.api.nvim_create_user_command("Q", "q<bang>", { bang = true })
vim.api.nvim_create_user_command("Qa", "qa<bang>", { bang = true })
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("Wqa", "wqa", {})
vim.api.nvim_create_user_command("Vs", "vs", {})
vim.api.nvim_create_user_command("E", "e", {})

-- save without auto format
vim.api.nvim_create_user_command("WW", "noa w", {})

vim.api.nvim_create_user_command("SourceThis", "source %", {})

vim.api.nvim_create_user_command("DiagEnable", function()
  vim.diagnostic.enable(true)
end, {})
vim.api.nvim_create_user_command("DiagDisable", function()
  vim.diagnostic.enable(false)
end, {})
vim.api.nvim_create_user_command("DiagToggle", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, {})

vim.api.nvim_create_user_command("DiagBufEnable", function()
  vim.diagnostic.enable(true, { bufnr = vim.api.nvim_get_current_buf() })
end, {})
vim.api.nvim_create_user_command("DiagBufDisable", function()
  vim.diagnostic.enable(false, { bufnr = vim.api.nvim_get_current_buf() })
end, {})
vim.api.nvim_create_user_command("DiagBufToggle", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
end, {})
