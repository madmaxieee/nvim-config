local inputMethodGroup = vim.api.nvim_create_augroup("InputMethod", { clear = true })

if vim.fn.has "mac" == 1 then
  -- store original input method when entering vim and leaving insert mode, then switch to english
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "InsertLeave" }, {
    group = inputMethodGroup,
    callback = function()
      vim.g.input_method = vim.fn.system({ "macism" }):match "[%w%.]+"
      vim.fn.system { "macism", "com.apple.keylayout.ABC" }
    end,
  })

  -- switch to english input method when exiting insert mode
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = inputMethodGroup,
    callback = function()
      vim.fn.system { "macism", vim.g.input_method }
    end,
  })
end
