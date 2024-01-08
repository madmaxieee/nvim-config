return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle" },
  keys = {
    {
      "<leader>T",
      mode = "n",
      function()
        require("trouble").toggle()
      end,
      desc = "Open Trouble",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    signs = {
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "",
    },
  },
}
