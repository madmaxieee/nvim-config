-- disable lsp diagnostic for certain file names
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("DisableLsp", { clear = true }),
  pattern = { ".env*" },
  callback = function()
    vim.diagnostic.disable()
  end,
})
