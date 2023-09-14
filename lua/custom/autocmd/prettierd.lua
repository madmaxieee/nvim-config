if vim.fn.executable "prettierd" then
  vim.api.nvim_create_autocmd({ "VimEnter" }, {
    group = vim.api.nvim_create_augroup("prettierd", { clear = true }),
    callback = function()
      vim.fn.jobstart { "prettierd", "restart" }
    end,
  })
end
