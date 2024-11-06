return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewFileHistory",
  },
  init = function()
    vim.cmd.cabbrev("Diff", "DiffviewOpen")
  end,
  opts = {
    hooks = {
      diff_buf_read = function(bufnr)
        vim.opt_local.wrap = false
        vim.opt_local.buflisted = false
        local map_repeatable_pair = require("utils").map_repeatable_pair
        map_repeatable_pair({ "n", "x", "o" }, {
          next = {
            "]h",
            function()
              vim.cmd.normal { "]c", bang = true }
            end,
            { desc = "Next hunk", buffer = bufnr },
          },
          prev = {
            "[h",
            function()
              vim.cmd.normal { "[c", bang = true }
            end,
            { desc = "Previous hunk", buffer = bufnr },
          },
        })
      end,
    },
  },
}
