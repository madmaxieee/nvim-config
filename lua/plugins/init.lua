return {
  { "nvim-lua/plenary.nvim" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  {
    "tpope/vim-sleuth",
    event = "VeryLazy",
  },
}
