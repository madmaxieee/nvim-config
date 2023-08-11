vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  group = vim.api.nvim_create_augroup("guess-indent", { clear = true }),
  callback = function()
    vim.cmd "silent GuessIndent"
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = vim.api.nvim_create_augroup("barbecue", { clear = true }),
  callback = function()
    require("barbecue.ui").update()
  end,
})
