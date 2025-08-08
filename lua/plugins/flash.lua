return {
  "folke/flash.nvim",
  opts = {
    highlight = {
      priority = 10000,
    },
    modes = {
      char = {
        enabled = false,
      },
    },
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
        require("keymap-benchmark").record(vim.api.nvim_get_mode().mode, "s")
      end,
      desc = "Flash",
    },
  },
}
