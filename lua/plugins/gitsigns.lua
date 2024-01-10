local map = require("utils").safe_keymap_set

return {
  "lewis6991/gitsigns.nvim",
  ft = { "gitcommit", "diff" },
  init = function()
    -- load gitsigns only when a git file is opened
    vim.api.nvim_create_autocmd({ "BufRead" }, {
      group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
      callback = function()
        if vim.g.loaded_gitsigns then
          return
        end
        vim.fn.system("git -C " .. '"' .. vim.fn.expand "%:p:h" .. '"' .. " rev-parse")
        if vim.v.shell_error == 0 then
          vim.api.nvim_del_augroup_by_name "GitSignsLazyLoad"
          vim.schedule(function()
            require("lazy").load { plugins = { "gitsigns.nvim" } }
          end)
        end
        vim.g.loaded_gitsigns = true
      end,
    })
  end,
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "󰍵" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "│" },
    },
    on_attach = function(bufnr)
      local gs = require "gitsigns"

      map("n", "]h", function()
        if vim.wo.diff then
          return "]h"
        end
        vim.schedule(gs.next_hunk)
        return "<Ignore>"
      end, { desc = "Next hunk", buffer = bufnr })

      map("n", "[h", function()
        if vim.wo.diff then
          return "[h"
        end
        vim.schedule(gs.prev_hunk)
        return "<Ignore>"
      end, { desc = "Previous hunk", buffer = bufnr })

      map("n", "<leader>gb", gs.blame_line, { desc = "Blame line", buffer = bufnr })
      map("n", "<leader>gd", gs.toggle_deleted, { desc = "Toggle Deleted", buffer = bufnr })
      map("n", "<leader>rh", gs.reset_hunk, { desc = "Reset hunk", buffer = bufnr })
    end,
  },
}
