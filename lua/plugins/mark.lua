return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  config = function()
    local marks = require("marks")
    local marks_utils = require("marks.utils")

    local utils = require("utils")
    local map = utils.safe_keymap_set

    marks.setup({
      default_mappings = false,
      mappings = {
        set = "m",
        set_next = "m,",
        toggle = "m;",
      },
    })

    map("n", "dm", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      local input = vim.fn.nr2char(vim.fn.getchar())
      if input == "-" then
        marks.delete_line()
      elseif input == " " then
        marks.delete_buf()
      elseif marks_utils.is_valid_mark(input) then
        marks.mark_state:delete_mark(input)
      end
    end, { desc = "delete mark" })

    utils.map_repeatable_pair("n", {
      next = { "]M", marks.next, { desc = "next mark" } },
      prev = { "[M", marks.prev, { desc = "previous mark" } },
    })
  end,
}
