vim.opt.relativenumber = true
vim.opt.scrolloff = 8

vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = false
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

require "custom.usercmd"
require "custom.autocmd"
