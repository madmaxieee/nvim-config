return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle" },
  keys = {
    {
      "<leader>q",
      mode = "n",
      "<cmd>Trouble document_diagnostics<CR>",
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
