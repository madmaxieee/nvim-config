-- Compare clipboard to current buffer
vim.api.nvim_create_user_command("DiffClipboard", function()
  local ftype = vim.bo.filetype -- original filetype

  vim.cmd "tabnew %" -- Open current file in a new tab

  vim.cmd.vnew()
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
  vim.cmd.normal { "P", bang = true }

  vim.cmd "windo diffthis" -- Start diffing

  vim.opt_local.filetype = ftype
end, { nargs = 0 })

return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewFileHistory",
  },
  init = function()
    vim.cmd.cabbrev("D", "DiffviewOpen")
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
