return {
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
}
