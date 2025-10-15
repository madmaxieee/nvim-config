return {
  cond = require("modes").google3_mode,
  "yairhochner/google-snacks.nvim",
  url = "sso://user/yairhochner/google-snacks.nvim",
  lazy = false,
  dependencies = {
    {
      "folke/snacks.nvim",
      opts = { picker = { enabled = true } },
    },
  },

  keys = {
    {
      "<leader>hx",
      function()
        require("google-snacks").fig.xl()
      end,
      desc = "Fig XL",
    },

    {
      "<leader>cs",
      function()
        require("google-snacks").codesearch.query()
      end,
      desc = "codesearch query",
    },
  },

  config = function()
    require("snacks").picker.git_status = require("google-snacks").fig.status
  end,
}
