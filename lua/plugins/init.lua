return {
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  {
    enabled = false,
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  {
    -- enabled = false,
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      vim.cmd.colorscheme "tokyonight-night"
    end,
  },
  {
    "tpope/vim-sleuth",
    event = { "BufRead", "BufNewFile" },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      {
        "<leader>o",
        mode = "n",
        "<cmd> Oil <CR>",
        desc = "Open Oil",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = true,
  },
  {
    "folke/neodev.nvim",
    ft = "lua",
    opts = {},
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "utilyre/barbecue.nvim",
    lazy = false,
    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("barbecue").setup {}
    end,
  },
}
