return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- {
    --   "rcarriga/nvim-notify",
    --   config = function()
    --     require("notify").setup {}
    --     vim.notify = require "notify"
    --   end,
    -- },
  },
  init = function()
    vim.opt.cmdheight = 0
  end,
  opts = {},
}
