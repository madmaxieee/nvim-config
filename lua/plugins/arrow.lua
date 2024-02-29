return {
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
    {
      "<leader>a",
      mode = "n",
      function()
        local filename = require("arrow.utils").get_path_for "%"
        require("arrow.persist").save(filename)
      end,
      desc = "Add to arrow",
    },
  },
  opts = {
    show_icons = true,
    leader_key = ";",
    separate_save_and_remove = true,
    index_keys = "asdfghjkl123456789",
    mappings = {
      edit = "e",
      delete_mode = "D",
      clear_all_items = "C",
      -- used as save if separate_save_and_remove is true
      toggle = "S",
      open_vertical = "v",
      open_horizontal = "-",
      quit = "q",
      -- only used if separate_save_and_remove is true
      remove = "x",
    },
  },
}
