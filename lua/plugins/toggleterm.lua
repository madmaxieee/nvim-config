---@type Terminal
local _TERM
---@type Terminal
local _LAZYJJ_OR_GIT_TERM

return {
  {
    cond = not require("flags").is_minimal,
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = {
      {
        "<A-q>",
        mode = { "n", "t" },
        function()
          _TERM:toggle(nil, "float")
        end,
        desc = "Toggle terminal",
      },
      {
        "<A-i>",
        mode = { "n", "t" },
        function()
          _TERM:toggle(nil, "float")
        end,
        desc = "Toggle terminal",
      },
      {
        "<leader>j",
        mode = { "n", "t" },
        function()
          _LAZYJJ_OR_GIT_TERM:toggle(nil, "float")
        end,
        desc = "Toggle lazyjj or lazygit",
      },
    },

    opts = {
      float_opts = {
        border = "none",
      },
    },

    init = function()
      local Terminal = require("toggleterm.terminal").Terminal

      _TERM = Terminal:new({ float_opts = { border = "single" } })

      local jj_utils = require("utils.jj")
      local lazy_command
      if jj_utils.find_root() then
        local jj_bin = vim.fn.exepath("jj")
        lazy_command = ("lazyjj --jj-bin %s --ignore-jj-version"):format(jj_bin)
      else
        lazy_command = "lazygit"
      end

      _LAZYJJ_OR_GIT_TERM = Terminal:new({ cmd = lazy_command })
    end,
  },
}
