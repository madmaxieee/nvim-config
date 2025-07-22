return {
  "madmaxieee/marx.nvim",
  event = "BufReadPre",
  keys = {
    {
      "mm",
      mode = "n",
      function()
        require("marx").set_bookmark()
      end,
      desc = "set bookmark",
    },
    {
      "<leader>fm",
      mode = "n",
      function()
        require("marx").pick_mark()
      end,
      desc = "Pick bookmark",
    },
  },
  config = function()
    require("marx").setup()

    local utils = require "utils"
    utils.map_repeatable_pair("n", {
      next = {
        "]M",
        function()
          require("marx").next_mark { wrap = true }
        end,
        { desc = "next bookmark" },
      },
      prev = {
        "[M",
        function()
          require("marx").prev_mark { wrap = true }
        end,
        { desc = "prev bookmark" },
      },
    })
  end,
}
