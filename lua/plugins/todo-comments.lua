return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "TodoQuickFix", "TodoLocList", "TodoTrouble", "TodoTelescope" },
  keys = {
    {
      "<leader>td",
      mode = "n",
      "<cmd>TodoTrouble<cr>",
      desc = "Open todo list in trouble",
    },
    {
      "<leader>ft",
      mode = "n",
      "<cmd>TodoTelescope<cr>",
      desc = "Search for todos in telescope",
    },
    {
      "]t",
      mode = "n",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Next todo comment",
    },
    {
      "[t",
      mode = "n",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Previous todo comment",
    },
  },
  opts = {
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
      WARN = {
        icon = " ",
        color = "warning",
        alt = { "WARNING", "XXX" },
      },
      PERF = {
        icon = "󰅒",
        alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
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
    -- allow comments like these to work:
    -- NOTE -
    -- NOTE:
    highlight = {
      multiline = false,
      pattern = [[.*<(KEYWORDS)\s*(-|:)]],
    },
    search = {
      pattern = [[\b(KEYWORDS)(:|\s?-)]],
    },
  },
}
