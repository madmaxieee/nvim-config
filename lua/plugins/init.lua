return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
  },

  {
    "fei6409/log-highlight.nvim",
    ft = { "log" },
    opts = {},
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },

  {
    "tpope/vim-sleuth",
    event = { "BufReadPre", "BufNewFile" },
  },
}
