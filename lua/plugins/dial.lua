return {
  "monaqa/dial.nvim",
  keys = {
    {
      "<C-a>",
      function()
        require("dial.map").manipulate("increment", "normal")
      end,
      desc = "Increment",
    },
    {
      "<C-x>",
      function()
        require("dial.map").manipulate("decrement", "normal")
      end,
      desc = "Decrement",
    },
    {
      "g<C-a>",
      function()
        require("dial.map").manipulate("increment", "gnormal")
      end,
      desc = "Increment sequentially",
    },
    {
      "g<C-x>",
      function()
        require("dial.map").manipulate("decrement", "gnormal")
      end,
      desc = "Decrement sequentially",
    },
    {
      "<C-a>",
      mode = "x",
      function()
        require("dial.map").manipulate("increment", "visual")
      end,
      desc = "Increment",
    },
    {
      "<C-x>",
      mode = "x",
      function()
        require("dial.map").manipulate("decrement", "visual")
      end,
      desc = "Decrement",
    },
    {
      "g<C-a>",
      mode = "x",
      function()
        require("dial.map").manipulate("increment", "gvisual")
      end,
      desc = "Increment sequentially",
    },
    {
      "g<C-x>",
      mode = "x",
      function()
        require("dial.map").manipulate("decrement", "gvisual")
      end,
      desc = "Decrement sequentially",
    },
  },

  config = function()
    local augend = require("dial.augend")
    require("dial.config").augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.constant.alias.bool,
        augend.date.new({
          pattern = "%Y-%m-%d",
          default_kind = "day",
          only_valid = true,
        }),
        augend.date.new({
          pattern = "%Y/%m/%d",
          default_kind = "day",
          only_valid = true,
        }),
        augend.date.new({
          pattern = "%m/%d/%Y",
          default_kind = "day",
          only_valid = true,
        }),
        augend.semver.alias.semver,
      },
    })
  end,
}
