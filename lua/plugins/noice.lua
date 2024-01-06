return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      config = function()
        require("notify").setup {}
        vim.notify = require "notify"
      end,
    },
  },
  init = function()
    vim.opt.cmdheight = 0
  end,
  opts = {
    lsp = {
      hover = {
        enabled = false,
      },
      signature = {
        enabled = false,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
    },
    views = {
      cmdline_popup = {
        position = {
          row = -3,
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      },
      popupmenu = {
        relative = "editor",
        position = {
          row = -14,
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
        },
      },
    },
  },
}
