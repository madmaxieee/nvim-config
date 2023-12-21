-- disable lsp diagnostic for certain file names
local disable_lsp_group = vim.api.nvim_create_augroup("DisableLsp", { clear = true })

local function detach_all_lsp_client(event)
  local lsp_clients = vim.lsp.get_clients { bufnr = event.buf }
  for _, client in ipairs(lsp_clients) do
    -- vim.notify("Detaching " .. client.name .. " from " .. event.buf)
    vim.lsp.buf_detach_client(event.buf, client.id)
  end
end
-- don't show diagnostics for NvimTree
vim.api.nvim_create_autocmd("BufEnter", {
  group = disable_lsp_group,
  callback = function(event)
    if vim.bo.filetype == "NvimTree" then
      detach_all_lsp_client(event)
      vim.diagnostic.disable(event.buf)
      return
    end
  end,
})
