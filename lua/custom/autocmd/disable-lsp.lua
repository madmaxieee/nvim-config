-- disable lsp diagnostic for certain file names
local disable_lsp_group = vim.api.nvim_create_augroup("DisableLsp", { clear = true })

local patterns = {
  ".env*",
}

local function disable_lsp(pattern)
  vim.api.nvim_create_autocmd("BufEnter", {
    group = disable_lsp_group,
    pattern = pattern,
    callback = function()
      vim.diagnostic.disable()
    end,
  })
end

for _, pattern in ipairs(patterns) do
  disable_lsp(pattern)
end
