local float_window_config = require("utils").float_window_config

return {
  "stevearc/oil.nvim",
  cmd = "Oil",
  keys = {
    {
      "<leader>o",
      mode = "n",
      function()
        require("oil").toggle_float()
      end,
      desc = "Open Oil",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    keymaps = {
      ["<leader><Space>"] = function()
        require("oil").save()
        require("oil").toggle_float()
      end,
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = true,
    },
    -- Configuration for the floating window in oil.open_float
    float = {
      override = function()
        return float_window_config(0.7, 0.4, {})
      end,
    },
  },
  config = true,
}
