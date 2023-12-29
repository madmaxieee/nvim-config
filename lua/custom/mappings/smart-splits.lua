local smart_splits_mappings = {
  plugin = true,
  n = {
    ["H"] = {
      function()
        require("smart-splits").resize_left()
      end,
      "resize left",
    },
    ["L"] = {
      function()
        require("smart-splits").resize_right()
      end,
      "resize right",
    },
    ["<leader>L"] = {
      function()
        require("smart-splits").swap_buf_right()
      end,
      "swap buffer right",
    },
    ["<leader>H"] = {
      function()
        require("smart-splits").swap_buf_left()
      end,
      "swap buffer left",
    },
    ["<leader>J"] = {
      function()
        require("smart-splits").swap_buf_down()
      end,
      "swap buffer down",
    },
    ["<leader>K"] = {
      function()
        require("smart-splits").swap_buf_up()
      end,
      "swap buffer up",
    },
  },
}

return smart_splits_mappings
