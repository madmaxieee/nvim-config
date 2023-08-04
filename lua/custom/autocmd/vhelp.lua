-- open help in vertical split
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("Help", { clear = true }),
  pattern = "help",
  callback = function()
    vim.cmd "wincmd L"
  end,
})
