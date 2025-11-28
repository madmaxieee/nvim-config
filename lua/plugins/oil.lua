return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Oil",
  keys = {
    {
      "<leader>o",
      mode = "n",
      function()
        local oil = require "oil"
        if vim.w.is_oil_win then
          oil.close()
        else
          oil.open_float(nil, nil, vim.schedule_wrap(oil.open_preview))
        end
      end,
      desc = "Toggle oil",
    },
    {
      "-",
      mode = "n",
      "<cmd> Oil <cr>",
      desc = "Open oil",
    },
  },
  opts = {
    float = {
      border = "rounded",
      max_width = 0.6,
      max_height = 0.7,
    },
    preview_win = {
      win_options = {
        wrap = false,
      },
    },
    keymaps = {
      ["<C-h>"] = {},
    },
  },
}
