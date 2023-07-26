vim.opt.relativenumber = true
vim.opt.scrolloff = 8

vim.opt.encoding = "utf8"
vim.opt.fileencoding = "utf8"

vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

require "custom.usercmd"
require "custom.autocmd"
