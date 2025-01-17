-- auto reload files when changed outside of neovim
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  desc = "Auto reload files when changed outside of neovim",
  callback = function()
    vim.cmd "checktime"
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
  end,
})

-- restore cursor position
vim.api.nvim_create_autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("RestoreCursorPos", { clear = true }),
  desc = "Restore cursor position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd 'normal! g`"'
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("ResizeWindows", { clear = true }),
  desc = "Resize windows when vim is resized",
  command = "wincmd =",
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

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("LspSemanticHL", { clear = true }),
  desc = "Disable LSP semantic highlight",
  callback = function()
    for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
      vim.api.nvim_set_hl(0, group, {})
    end
  end,
})
