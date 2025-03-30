vim.opt.scrolloff = 8
vim.opt.numberwidth = 2
vim.opt.number = true
vim.opt.ruler = false
vim.opt.signcolumn = "yes"

vim.opt.cursorline = true
-- use underline cursor in virtual mode
vim.opt.guicursor = {
  "n-c-sm:block",
  "i-ci-ve:ver25",
  "v-r-cr-o:hor20",
}

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true

vim.opt.updatetime = 250
vim.opt.timeoutlen = 250

vim.opt.foldlevel = 20
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
vim.opt.foldmethod = "expr"

vim.opt.linebreak = true

-- disable nvim intro
vim.opt.shortmess:append "sI"

-- make h and l wrap lines
vim.opt.whichwrap:append "<>[]hl"

-- yank to system clipboard
-- vim.opt.clipboard = "unnamedplus"

-- make undo persistent
vim.opt.undofile = true

vim.opt.diffopt:append {
  "linematch:60",
  "algorithm:patience",
}

-- HACK: :Inspect for some reason references vim.hl instead of vim.highlight
vim.hl = vim.highlight

vim.g.mapleader = vim.keycode "<space>"
vim.g.maplocalleader = "\\"

vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = "󰋼 ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
}
