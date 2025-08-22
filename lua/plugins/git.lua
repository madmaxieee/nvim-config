local map_repeatable_pair = require("utils").map_repeatable_pair
local map = require("utils").safe_keymap_set

-- load gitsigns only when a git file is opened
vim.api.nvim_create_autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
  callback = function()
    if vim.g.loaded_gitsigns then
      return
    end
    if vim.v.shell_error == 0 then
      vim.api.nvim_del_augroup_by_name "GitSignsLazyLoad"
      require("lazy").load { plugins = { "gitsigns.nvim" } }
      vim.api.nvim_create_user_command("GitBlame", "Gitsigns blame", {})
      vim.g.loaded_gitsigns = true
    end
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
    event = { "BufReadPre" },
    config = function()
      local gitconflict = require "git-conflict"
      ---@diagnostic disable-next-line: missing-fields
      gitconflict.setup { default_mappings = false }

      map({ "n", "v" }, "<leader>co", function()
        gitconflict.choose "ours"
      end, { desc = "Choose ours" })
      map({ "n", "v" }, "<leader>ct", function()
        gitconflict.choose "theirs"
      end, { desc = "Choose theirs" })
      map({ "n", "v" }, "<leader>cb", function()
        gitconflict.choose "both"
      end, { desc = "Choose both" })
      map({ "n", "v" }, "<leader>cn", function()
        gitconflict.choose "none"
      end, { desc = "Choose none" })

      map_repeatable_pair({ "n" }, {
        next = {
          "]x",
          function()
            gitconflict.find_next "ours"
          end,
          { desc = "Next conflict" },
        },
        prev = {
          "[x",
          function()
            gitconflict.find_prev "ours"
          end,
          { desc = "Previous conflict" },
        },
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    ft = { "gitcommit", "diff" },
    opts = {
      current_line_blame = true,
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

        map_repeatable_pair({ "n" }, {
          next = {
            "]h",
            function()
              if vim.wo.diff then
                vim.cmd.normal { "]c", bang = true }
              else
                ---@diagnostic disable-next-line: param-type-mismatch
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
                ---@diagnostic disable-next-line: param-type-mismatch
                gs.nav_hunk "prev"
              end
            end,
            { desc = "Previous hunk", buffer = bufnr },
          },
        })

        map("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "toggle line blame", buffer = bufnr })
        ---@diagnostic disable-next-line: deprecated
        map("n", "<leader>gd", gs.toggle_deleted, { desc = "toggle deleted", buffer = bufnr })
        map("n", "<leader>ga", gs.stage_buffer, { desc = "stage buffer", buffer = bufnr })
        map("n", "<leader>gu", gs.stage_buffer, { desc = "undo stage buffer", buffer = bufnr })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "reset hunk", buffer = bufnr })
        map("n", "<leader>hs", gs.stage_hunk, { desc = "stage hunk", buffer = bufnr })
        map({ "o", "x" }, "ih", gs.select_hunk, { desc = "select hunk", buffer = bufnr })
      end,
    },
  },
}
