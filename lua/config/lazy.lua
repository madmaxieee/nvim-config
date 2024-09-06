local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
    version = false, -- always use the latest git commit
  },
  install = {
    missing = false,
    colorscheme = { "tokyonight" },
  },
  checker = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}
