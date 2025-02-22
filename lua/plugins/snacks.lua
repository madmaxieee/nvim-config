local repeatable = require "repeatable"
local next_ref_repeat, prev_ref_repeat = repeatable.make_repeatable_move_pair( --
  function()
    Snacks.words.jump(vim.v.count1, true)
  end,
  function()
    Snacks.words.jump(-vim.v.count1, true)
  end
)

local function snacks_debug()
  _G.dd = function(...)
    Snacks.debug.inspect(...)
  end
  _G.bt = function()
    Snacks.debug.backtrace()
  end
  vim.print = _G.dd
end

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

  init = function()
    vim.api.nvim_create_autocmd("BufRead", {
      group = vim.api.nvim_create_augroup("SnacksDebug", { clear = true }),
      desc = "Setup snacks debug",
      pattern = (vim.fn.expand "~/.local/share/nvim/lazy/") .. "*",
      once = true,
      callback = snacks_debug,
    })
  end,

  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    image = { enabled = true },
    indent = { enabled = false },
    input = { enabled = true },
    notifier = { enabled = false },
    picker = {
      enabled = true,
      ui_select = true,
    },
    quickfile = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      input = {
        row = 1,
        relative = "cursor",
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    vim.api.nvim_create_user_command("SnacksDebug", snacks_debug, {})
  end,
}
