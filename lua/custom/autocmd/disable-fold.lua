-- disable folding for certain filetypes
local disabled_fts = {
  terminal = true,
  nvcheatsheet = true,
  help = true,
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufNew" }, {
  group = vim.api.nvim_create_augroup("DisableFold", { clear = true }),
  callback = function()
    local ft = vim.bo.filetype
    if disabled_fts[ft] then
      vim.wo.foldcolumn = "0"
      vim.wo.foldenable = false
      vim.wo.foldmethod = "manual"
    end
  end,
})
