return {
  "madmaxieee/marx.nvim",
  event = "BufReadPre",
  keys = {
    {
      "mm",
      mode = "n",
      function()
        require("marx").set_bookmark()
        require("keymap-benchmark").record("n", "mm")
      end,
      desc = "set bookmark",
    },
    {
      "<leader>fm",
      mode = "n",
      function()
        require("marx").pick_mark()
        require("keymap-benchmark").record("n", "<leader>fm")
      end,
      desc = "Pick bookmark",
    },
  },
  config = function()
    require("marx").setup()

    local utils = require "utils"
    utils.map_repeatable_pair("n", {
      next = {
        "]m",
        function()
          require("marx").next_mark { wrap = true }
        end,
        { desc = "next bookmark" },
      },
      prev = {
        "[m",
        function()
          require("marx").prev_mark { wrap = true }
        end,
        { desc = "prev bookmark" },
      },
    })
  end,
}
