return {
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "yz", -- Add surrounding in Normal and Visual modes
        delete = "dz", -- Delete surrounding
        find = "", -- Find surrounding (to the right)
        find_left = "", -- Find surrounding (to the left)
        highlight = "", -- Highlight surrounding
        replace = "cz", -- Replace surrounding
        update_n_lines = "", -- Update `n_lines`

        suffix_last = "", -- Suffix to search with "prev" method
        suffix_next = "", -- Suffix to search with "next" method
      },
      n_lines = 20,
    },
  },

  {
    "nvim-mini/mini.diff",
    event = "VeryLazy",
    opts = {
      view = {
        style = "sign",
        signs = {
          add = "│",
          change = "│",
          delete = "󰍵",
        },
      },
      mappings = {
        apply = "",
        reset = "",
        textobject = "",
        goto_first = "",
        goto_prev = "",
        goto_next = "",
        goto_last = "",
      },
      options = {
        algorithm = "patience",
      },
    },

    init = function()
      local map_repeatable_pair = require("utils").map_repeatable_pair
      local map = require("utils").safe_keymap_set

      map_repeatable_pair({ "n" }, {
        next = {
          "]h",
          function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              require("mini.diff").goto_hunk("next", { wrap = true })
            end
          end,
          { desc = "Next hunk" },
        },
        prev = {
          "[h",
          function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              require("mini.diff").goto_hunk("prev", { wrap = true })
            end
          end,
          { desc = "Previous hunk" },
        },
      })

      map("n", "<leader>hr", function()
        require("mini.diff").do_hunks(0, "reset")
      end, { desc = "Reset hunk" })
      map({ "o", "x" }, "ih", function()
        require("mini.diff").textobject()
      end, { desc = "Current hunk text object" })
    end,
  },
}
