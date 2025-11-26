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
  local new_value = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(new_value)
  vim.notify("Diagnostics " .. (new_value and "enabled" or "disabled"))
end, {})

vim.api.nvim_create_user_command("DiagBufEnable", function()
  vim.diagnostic.enable(true, { bufnr = vim.api.nvim_get_current_buf() })
end, {})
vim.api.nvim_create_user_command("DiagBufDisable", function()
  vim.diagnostic.enable(false, { bufnr = vim.api.nvim_get_current_buf() })
end, {})
vim.api.nvim_create_user_command("DiagBufToggle", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local new_value = not vim.diagnostic.is_enabled { bufnr = bufnr }
  vim.diagnostic.enable(new_value, { bufnr = bufnr })
  vim.notify("Diagnostics for current buffer " .. (new_value and "enabled" or "disabled"))
end, {})

vim.api.nvim_create_user_command("InlayHintToggle", function()
  local new_value = not vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(new_value)
  vim.notify("Inlay hints " .. (new_value and "enabled" or "disabled"))
end, {})

vim.api.nvim_create_user_command("Diffthis", "windo diffthis", {})
vim.api.nvim_create_user_command("Diffoff", "windo diffoff", {})

vim.api.nvim_create_user_command("CdBuf", "cd %:h", {})
