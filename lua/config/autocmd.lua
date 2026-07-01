-- auto reload files when changed outside of neovim
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  desc = "Auto reload files when changed outside of neovim",
  callback = function()
    vim.cmd("checktime")
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.hl_op({ higroup = "Visual", timeout = 200 })
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
      vim.cmd('normal! g`"')
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("ResizeWindows", { clear = true }),
  desc = "Resize windows when vim is resized",
  command = "wincmd =",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("FileChangeNotify", { clear = true }),
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
  desc = "Notify when a file is changed externally",
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("HerdrRenamePane", { clear = true }),
  desc = "Rename herdr pane to nvim if inside herdr",
  callback = function()
    local herdr_pane_id = vim.env.HERDR_PANE_ID
    if herdr_pane_id and herdr_pane_id ~= "" then
      vim.system({ "herdr", "pane", "rename", herdr_pane_id, "nvim" })
    end
  end,
})
