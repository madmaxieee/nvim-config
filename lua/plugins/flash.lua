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
      end,
      desc = "Flash",
    },
    {
      "v",
      mode = { "v" },
      function()
        require("flash").treesitter({
          actions = {
            ["v"] = "next",
            ["V"] = "prev",
          },
        })
      end,
      desc = "Treesitter incremental selection",
    },
  },
}
