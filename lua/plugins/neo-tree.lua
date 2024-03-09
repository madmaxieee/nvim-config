local is_opening_dir = vim.fn.argc() > 0 and vim.fn.isdirectory(vim.fn.argv()[0])

return {
  enabled = not vim.g.minimal_mode,
  -- don't lazy load if opening a directory, since we want to hijack netrw
  lazy = not is_opening_dir,
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<C-n>",
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
  init = function()
    -- disable netrw
    vim.g.loaded_netrwPlugin = true
    vim.g.loaded_netrw = true
    vim.g.loaded_netrw_gitignore = true
  end,
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
      },
    },
  },
}
