return {
  "gbprod/yanky.nvim",
  opts = {
    highlight = {
      on_put = true,
      on_yank = false,
    },
  },
  dependencies = { "folke/snacks.nvim" },
  keys = {
    {
      "<leader>p",
      function()
        ---@diagnostic disable-next-line: undefined-field
        require("snacks").picker.yanky()
      end,
      mode = { "n", "x" },
      desc = "Open Yank History",
    },
  },
}
