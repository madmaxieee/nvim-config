-- disable lsp diagnostic for certain file names
local disable_lsp_group = vim.api.nvim_create_augroup("DisableLsp", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = disable_lsp_group,
  pattern = { ".env*" },
  callback = function(bufnr)
    vim.diagnostic.disable(bufnr)
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  group = disable_lsp_group,
  pattern = { ".env*" },
  callback = function(bufnr)
    vim.diagnostic.enable(bufnr)
  end,
})
