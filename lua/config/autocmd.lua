-- auto reload files when changed outside of neovim
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  callback = function()
    vim.cmd "checktime"
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
  end,
})

local color_utils = require "utils.colors"
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("ColorUtils", { clear = true }),
  callback = function()
    local normal_highlight = vim.api.nvim_get_hl(0, { name = "Normal" })
    color_utils.fg = normal_highlight.fg
    color_utils.bg = normal_highlight.bg
  end,
})
