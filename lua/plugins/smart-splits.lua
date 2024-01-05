return {
  "mrjones2014/smart-splits.nvim",
  keys = {
    {
      "H",
      mode = "n",
      function()
        require("smart-splits").resize_left()
      end,
      desc = "resize left",
    },
    {
      "L",
      mode = "n",
      function()
        require("smart-splits").resize_right()
      end,
      desc = "resize right",
    },
    {
      "<leader>H",
      mode = "n",
      function()
        require("smart-splits").swap_buf_left()
      end,
      desc = "swap buffer left",
    },
    {
      "<leader>J",
      mode = "n",
      function()
        require("smart-splits").swap_buf_down()
      end,
    },
    {
      "<leader>K",
      mode = "n",
      function()
        require("smart-splits").swap_buf_up()
      end,
    },
    {
      "<leader>L",
      mode = "n",
      function()
        require("smart-splits").swap_buf_right()
      end,
      desc = "swap buffer right",
    },
  },
  opts = {
    default_amount = 5,
    resize_mode = {
      quit_key = "<ESC>",
      resize_keys = { "h", "j", "k", "l" },
      silent = true,
      hooks = {
        on_enter = nil,
        on_leave = nil,
      },
    },
  },
  config = true,
}
