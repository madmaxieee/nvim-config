vim.opt.scrolloff = 8
vim.opt.numberwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.ruler = false
vim.opt.signcolumn = "yes"

-- disable nvim intro
vim.opt.shortmess:append "sI"

-- make h and l wrap lines
vim.opt.whichwrap:append "<>[]hl"

-- yank to system clipboard
vim.opt.clipboard = "unnamedplus"

-- make undo persistent
vim.opt.undofile = true

vim.g.mapleader = " "
