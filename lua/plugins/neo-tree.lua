local is_opening_dir = vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv()[1])

return {
  cond = not require("modes").minimal_mode,
  -- don't lazy load if opening a directory, since we want to hijack netrw
  lazy = not is_opening_dir,
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<leader>n",
      mode = "n",
      "<cmd> Neotree toggle <CR>",
      desc = "open NeoTree",
    },
  },
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
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
    filesystem = {
      hijack_netrw_behavior = "open_default",
    },
    window = {
      position = "float",
      mappings = {
        ["s"] = "",
        ["<space>"] = "",
      },
    },
  },
}
