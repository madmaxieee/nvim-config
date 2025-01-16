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
  },

  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    indent = {
      enabled = true,
      indent = {
        char = "▎",
      },
      scope = {
        char = "▎",
        underline = true,
      },
      animate = {
        duration = {
          step = 10, -- ms per step
          total = 500, -- maximum duration
        },
      },
    },
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

  init = function()
    vim.api.nvim_create_autocmd("BufRead", {
      group = vim.api.nvim_create_augroup("NoSnacksIndent", { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].filetype == "markdown" then
          vim.b[args.buf].snacks_indent = false
        end
      end,
    })
  end,

  config = function(_, opts)
    require("snacks").setup(opts)
    local snacks_indent_hl = vim.api.nvim_get_hl(0, { name = "SnacksIndent" })
    vim.api.nvim_set_hl(0, "SnacksIndent", { fg = snacks_indent_hl.fg })
    local snacks_scope_hl = vim.api.nvim_get_hl(0, { name = "SnacksIndentScope" })
    vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = snacks_scope_hl.fg })
  end,
}
