return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "TodoQuickFix", "TodoLocList", "TodoTrouble" },
  keys = {
    {
      "<leader>td",
      mode = "n",
      "<cmd> TodoTrouble <cr>",
      desc = "Open todo list in trouble",
    },
    {
      "<leader>ft",
      mode = "n",
      function()
        ---@diagnostic disable-next-line: undefined-field
        require("snacks").picker.todo_comments()
      end,
      desc = "Search for todos in snacks picker",
    },
  },

  config = function()
    require("todo-comments").setup {
      keywords = {
        DEBUG = {
          icon = " ",
          color = "warning",
        },
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
        },
        TODO = {
          icon = " ",
          color = "info",
        },
        HACK = {
          icon = " ",
          color = "warning",
        },
        WHY = {
          icon = "? ",
          color = "warning",
          alt = { "WTF", "WHAT" },
        },
        WARN = {
          icon = " ",
          color = "warning",
          alt = { "WARNING" },
        },
        PERF = {
          icon = "󰅒",
          alt = { "PERFORMANCE", "OPTIM", "OPTIMIZE" },
        },
        NOTE = {
          icon = "",
          color = "hint",
          alt = { "INFO" },
        },
        TEST = {
          icon = "⏲ ",
          color = "test",
          alt = { "TESTING", "PASSED", "FAILED" },
        },
      },
      -- allow comments like these to work
      -- NOTE -
      -- NOTE:
      -- TODO(b/123): test
      highlight = {
        multiline = true,
        -- pattern or table of patterns, used for highlighting (very magic vim regex)
        -- pattern = [=[.*<(KEYWORDS)\s?[:-]]=],
        pattern = [=[.*<(KEYWORDS)[ 0-9()b/]*[:-]]=],
      },
      search = {
        -- pattern = [=[\b(KEYWORDS)\s?[:-]]=],
        pattern = [=[\b(KEYWORDS)(\(b/\d+\))?\s?[:-]]=],
      },
    }

    local utils = require "utils"
    utils.map_repeatable_pair("n", {
      next = {
        "]T",
        function()
          require("todo-comments").jump_next()
        end,
        { desc = "next todo comment" },
      },
      prev = {
        "[T",
        function()
          require("todo-comments").jump_prev()
        end,
        { desc = "prev todo comment" },
      },
    })
  end,
}
