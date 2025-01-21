local repeatable = require "repeatable"
local next_ref_repeat, prev_ref_repeat = repeatable.make_repeatable_move_pair( --
  function()
    Snacks.words.jump(vim.v.count1, true)
  end,
  function()
    Snacks.words.jump(-vim.v.count1, true)
  end
)

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<leader>x",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "]]",
      next_ref_repeat,
      desc = "Next Reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      prev_ref_repeat,
      desc = "Prev Reference",
      mode = { "n", "t" },
    },
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
  },

  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    indent = { enabled = false },
    input = { enabled = true },
    notifier = { enabled = false },
    quickfile = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      ---@diagnostic disable-next-line: missing-fields
      input = {
        row = 1,
        relative = "cursor",
      },
    },
  },
}
