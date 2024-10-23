return {
  cond = not vim.g.minimal_mode,
  "otavioschwanck/arrow.nvim",
  keys = {
    ";",
    {
      "H",
      mode = "n",
      function()
        require("arrow.persist").previous()
      end,
      { desc = "Go to previous buffer" },
    },
    {
      "L",
      mode = "n",
      function()
        require("arrow.persist").next()
      end,
      { desc = "Go to next buffer" },
    },
  },
  opts = {
    show_icons = true,
    leader_key = ";",
    separate_save_and_remove = false,
    index_keys = "sfghjkzbnmwrtyuiopl123456789",
    mappings = {
      edit = "e",
      delete_mode = "d",
      clear_all_items = "c",
      -- used as save if separate_save_and_remove is true
      toggle = "a",
      open_vertical = "v",
      open_horizontal = "-",
      quit = "q",
      -- only used if separate_save_and_remove is true
      remove = "x",
    },
  },
}
