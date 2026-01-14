local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
    version = false, -- always use the latest git commit
  },
  install = {
    missing = true,
    colorscheme = { "tokyonight" },
  },
  checker = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "netrwPlugin",
        "spellfile",
        "tohtml",
      },
    },
  },
  rocks = {
    enabled = true,
  },
  ------@diagnostic disable-next-line: assign-type-mismatch
  ---dev = {
  ---  path = "~/plugins",
  ---  patterns = { "madmaxieee" },
  ---  fallback = true,
  ---},
})

vim.cmd.cabbrev("L", "Lazy")
