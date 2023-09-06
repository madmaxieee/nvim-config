-- disable lsp diagnostic for certain file names
local disabled_patterns = {
  "%.env.*",
}

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("DisableDiagnostic", { clear = true }),
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    for _, pattern in ipairs(disabled_patterns) do
      if string.match(bufname, pattern) then
        vim.diagnostic.disable(bufnr)
        return
      end
    end
  end,
})
