return {
  "madmaxieee/unclash.nvim",
  lazy = false,
  init = function()
    local utils = require("utils")
    utils.map_repeatable_pair("n", {
      next = {
        "]x",
        function()
          require("unclash").next_conflict({ wrap = true })
        end,
        { desc = "Go to next conflict" },
      },
      prev = {
        "[x",
        function()
          require("unclash").prev_conflict({ wrap = true })
        end,
        { desc = "Go to previous conflict" },
      },
    })

    utils.map_repeatable_pair("n", {
      next = {
        "]X",
        function()
          require("unclash").next_conflict({ wrap = true, bottom = true })
        end,
        { desc = "Go to next conflict (bottom marker)" },
      },
      prev = {
        "[X",
        function()
          require("unclash").prev_conflict({ wrap = true, bottom = true })
        end,
        { desc = "Go to previous conflict (bottom marker)" },
      },
    })
  end,
}
