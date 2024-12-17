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
  },
  init = function()
    vim.api.nvim_set_hl(0, "@comment.hint", { link = "@comment" })
    vim.api.nvim_set_hl(0, "@comment.info", { link = "@comment" })
    vim.api.nvim_set_hl(0, "@comment.note", { link = "@comment" })
    vim.api.nvim_set_hl(0, "@comment.todo", { link = "@comment" })
    vim.api.nvim_set_hl(0, "@comment.error", { link = "@comment" })
    vim.api.nvim_set_hl(0, "@comment.warning", { link = "@comment" })
  end,
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
      highlight = {
        multiline = true,
        pattern = [[.*<(KEYWORDS)\s*[:-]{1}]], -- pattern or table of patterns, used for highlighting (vim regex)
      },
      search = {
        pattern = [[\b(KEYWORDS)\s?[:-]{1}]],
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
