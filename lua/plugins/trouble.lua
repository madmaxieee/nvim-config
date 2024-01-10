return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle" },
  keys = {
    {
      "<leader>q",
      mode = "n",
      function()
        require("trouble").toggle()
      end,
      desc = "Open Trouble",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    auto_jump = {
      "lsp_definitions",
      "lsp_references",
      "lsp_implementations",
      "lsp_type_definitions",
    },
    signs = {
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "",
    },
  },
}
