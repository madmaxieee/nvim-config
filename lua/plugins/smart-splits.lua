return {
  "mrjones2014/smart-splits.nvim",
  keys = {
    {
      "<A-h>",
      mode = "n",
      function()
        require("smart-splits").resize_left()
      end,
      desc = "resize left",
    },
    {
      "<A-l>",
      mode = "n",
      function()
        require("smart-splits").resize_right()
      end,
      desc = "resize right",
    },
  },
  opts = {
    default_amount = 5,
    resize_mode = {
      resize_keys = { "h", "j", "k", "l" },
      silent = true,
    },
  },
}
