return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<C-n>",
      mode = "n",
      "<cmd> Neotree toggle position=float <CR>",
      desc = "open NeoTree",
    },
  },
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    "3rd/image.nvim",
  },
  opts = {
    default_component_configs = {
      git_status = {
        symbols = {
          -- Change type
          -- added = "+",
          -- modified = "",
          deleted = "✘",
          renamed = "»",
          -- Status type
          untracked = "?",
          ignored = "",
          unstaged = "󰄱",
          staged = "",
          conflict = "=",
        },
      },
    },
  },
}
