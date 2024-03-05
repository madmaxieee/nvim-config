return {
  "otavioschwanck/arrow.nvim",
  keys = {
    ";",
    {
      -- "H",
      "<S-Tab>",
      mode = "n",
      function()
        require("arrow.persist").previous()
      end,
      { desc = "Go to previous buffer" },
    },
    {
      -- "L",
      "<Tab>",
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
        vim.notify("Saved " .. filename .. " to arrow", vim.log.levels.INFO, { title = "Arrow" })
      end,
      desc = "Add current file to arrow",
    },
    {
      "<leader>x",
      mode = "n",
      function()
        local filename = require("arrow.utils").get_path_for "%"
        require("arrow.persist").remove(filename)
        vim.notify("Removed " .. filename .. " from arrow", vim.log.levels.INFO, { title = "Arrow" })
      end,
      desc = "Remove current file from arrow",
    },
  },
  opts = {
    show_icons = true,
    leader_key = ";",
    -- separate_by_branch = true, -- Bookmarks will be separated by git branch
    separate_save_and_remove = true,
    index_keys = "asdfghjkl123456789",
    mappings = {
      edit = "e",
      delete_mode = "D",
      clear_all_items = "c",
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
