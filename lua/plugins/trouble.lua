return {
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    keys = {
      {
        "<leader>q",
        mode = "n",
        function()
          local trouble = require "trouble"
          if trouble.is_open() then
            trouble.close()
          else
            vim.cmd "Trouble diagnostics toggle auto_jump=false"
          end
        end,
        desc = "Open Trouble",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local trouble = require "trouble"
      trouble.setup {
        auto_jump = true,
        signs = {
          error = "",
          warning = "",
          hint = "",
          information = "",
          other = "",
        },
        modes = {
          lsp_references = {
            params = { include_declaration = true },
          },
          lsp_base = {
            params = { include_current = true },
          },
        },
      }

      local utils = require "utils"
      utils.map_repeatable_pair("n", {
        next = {
          "]t",
          function()
            ---@diagnostic disable-next-line: missing-fields, missing-parameter
            trouble.next { jump = true, skip_groups = true }
          end,
          { desc = "jump to next trouble entry" },
        },
        prev = {
          "[t",
          function()
            ---@diagnostic disable-next-line: missing-fields, missing-parameter
            trouble.prev { jump = true, skip_groups = true }
          end,
          { desc = "jump to prev trouble entry" },
        },
      })
    end,
  },

  {
    "folke/snacks.nvim",
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      picker = {
        actions = {
          trouble_open = function(...)
            return require("trouble.sources.snacks").actions.trouble_open.action(...)
          end,
        },
        win = {
          input = {
            keys = {
              ["<c-t>"] = {
                "trouble_open",
                mode = { "n", "i" },
              },
            },
          },
        },
      },
    },
  },
}
