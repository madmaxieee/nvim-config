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
    -- Keep fork overrides after imports so they take precedence.
    {
      "lualine.nvim",
      url = "https://github.com/madmaxieee/lualine.nvim.git",
      branch = "disable-statusline-option",
    },
    {
      "snacks.nvim",
      url = "https://github.com/madmaxieee/snacks.nvim.git",
      branch = "downscale-png",
    },
  },
  defaults = {
    lazy = true,
    version = false, -- always use the latest git commit
  },
  concurrency = require("flags").low_ram and 1 or nil,
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
      },
    },
  },
  rocks = {
    enabled = true,
  },
  -- ---@diagnostic disable-next-line: assign-type-mismatch
  -- dev = {
  --   path = "~/plugins",
  --   patterns = { "madmaxieee" },
  --   fallback = true,
  -- },
})

vim.cmd.cabbrev("L", "Lazy")
