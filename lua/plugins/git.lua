-- load gitsigns only when a git file is opened
vim.api.nvim_create_autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
  callback = function()
    if vim.g.loaded_gitsigns then
      return
    end
    vim.fn.system("git -C " .. '"' .. vim.fn.expand "%:p:h" .. '"' .. " rev-parse")
    if vim.v.shell_error == 0 then
      vim.api.nvim_del_augroup_by_name "GitSignsLazyLoad"
      require("lazy").load {
        plugins = {
          "gitsigns.nvim",
          "git-conflict.nvim",
        },
      }
    end
    vim.api.nvim_create_user_command("GitBlame", "Gitsigns blame", {})
    vim.g.loaded_gitsigns = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("GitSignsFileType", { clear = true }),
  callback = function(opts)
    local ft = opts.match
    if ft == "gitsigns-blame" then
      vim.wo.winbar = " "
    end
  end,
})

return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    opts = {},
  },

  {
    "lewis6991/gitsigns.nvim",
    ft = { "gitcommit", "diff" },
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

        local map_repeatable_pair = require("utils").map_repeatable_pair
        map_repeatable_pair({ "n", "x", "o" }, {
          next = {
            "]h",
            function()
              if vim.wo.diff then
                vim.cmd.normal { "]c", bang = true }
              else
                gs.nav_hunk "next"
              end
            end,
            { desc = "Next hunk", buffer = bufnr },
          },
          prev = {
            "[h",
            function()
              if vim.wo.diff then
                vim.cmd.normal { "[c", bang = true }
              else
                gs.nav_hunk "prev"
              end
            end,
            { desc = "Previous hunk", buffer = bufnr },
          },
        })

        local map = require("utils").safe_keymap_set
        map("n", "<leader>gb", gs.blame_line, { desc = "blame line", buffer = bufnr })
        map("n", "<leader>gd", gs.toggle_deleted, { desc = "toggle deleted", buffer = bufnr })
        map("n", "<leader>ga", gs.stage_buffer, { desc = "stage buffer", buffer = bufnr })
        map("n", "<leader>gu", gs.stage_buffer, { desc = "undo stage buffer", buffer = bufnr })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "reset hunk", buffer = bufnr })
        map("n", "<leader>hs", gs.stage_hunk, { desc = "stage hunk", buffer = bufnr })
      end,
    },
  },
}
