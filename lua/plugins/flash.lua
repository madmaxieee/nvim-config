return {
  "pedro757/flash.nvim",
  branch = "fix/neovim-0.13-search-state",
  -- "folke/flash.nvim",
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
      mode = { "x" },
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
