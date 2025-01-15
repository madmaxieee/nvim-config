return {
  "LintaoAmons/bookmarks.nvim",
  event = "BufReadPre",
  dependencies = {
    { "kkharji/sqlite.lua" },
    { "nvim-telescope/telescope.nvim" },
  },
  keys = {
    {
      "mm",
      mode = "n",
      function()
        require("bookmarks").toggle_mark()
      end,
      desc = "Toggle bookmark",
    },
    {
      "<leader>fm",
      mode = "n",
      function()
        require("bookmarks").goto_bookmark()
      end,
      desc = "List bookmarks",
    },
  },

  config = function()
    local color_utils = require "utils.colors"
    local text_color = color_utils.hex(vim.api.nvim_get_hl(0, { name = "@property" }).fg)
    local bg_color = color_utils.hex(vim.api.nvim_get_hl(0, { name = "DiffAdd" }).bg)

    require("bookmarks").setup {
      signs = {
        mark = {
          icon = "󰃁",
          color = text_color,
          line_bg = bg_color,
        },
      },
    }

    local utils = require "utils"
    utils.map_repeatable_pair("n", {
      next = {
        "]b",
        function()
          require("bookmarks").goto_next_bookmark()
        end,
        { desc = "next bookmark" },
      },
      prev = {
        "[b",
        function()
          require("bookmarks").goto_prev_bookmark()
        end,
        { desc = "prev bookmark" },
      },
    })
  end,
}
