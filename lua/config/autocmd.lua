vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("VerticalHelp", { clear = true }),
  pattern = "help",
  callback = function()
    vim.cmd "wincmd L"
  end,
})
