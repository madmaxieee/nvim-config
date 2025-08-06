-- Compare clipboard to current buffer
vim.api.nvim_create_user_command("DiffClipboard", function()
  local ftype = vim.bo.filetype -- original filetype

  vim.cmd [[tabnew %]]

  vim.cmd.vnew()
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
  vim.cmd [[norm! "+P]]

  vim.cmd [[windo diffthis]]

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
      view_opened = function()
        if require("modes").difftool_mode then
          local diff_tab = vim.api.nvim_win_get_tabpage(0)
          for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
            if tab ~= diff_tab then
              vim.cmd.tabclose(tab)
            end
          end
        end
      end,
    },
  },
}
