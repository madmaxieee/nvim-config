return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle" },
  keys = {
    {
      "<leader>q",
      mode = "n",
      "<cmd>Trouble diagnostics toggle auto_jump=false<CR>",
      desc = "Open Trouble",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    auto_jump = true,
    signs = {
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "",
    },
  },
}
