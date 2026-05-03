return {
  {
    "dmtrKovalenko/fff.nvim",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false, -- make fff initialize on startup
  },

  {
    "madmaxieee/fff-snacks.nvim",
    lazy = false, -- lazy loaded by design
    ---@module 'fff_snacks'
    ---@type fff_snacks.Config
    opts = {
      find_files = {
        win = {
          input = {
            keys = {
              ["<C-f>"] = {
                "go_to_live_grep",
                mode = { "n", "i" },
                nowait = true,
              },
            },
          },
        },
      },
      live_grep = {
        win = {
          input = {
            keys = {
              ["<C-f>"] = {
                "go_to_find_files",
                mode = { "n", "i" },
                nowait = true,
              },
            },
          },
        },
      },
    },
    keys = {
      {
        "ff",
        function()
          require("fff-snacks").find_files()
        end,
        desc = "FFF find files",
      },
      {
        "fw",
        function()
          require("fff-snacks").live_grep()
        end,
        desc = "FFF live grep",
      },
      {
        mode = "x",
        "fw",
        function()
          require("fff-snacks").grep_word()
        end,
        desc = "FFF grep word",
      },
      {
        "fz",
        function()
          require("fff-snacks").live_grep({
            grep_mode = { "fuzzy", "plain", "regex" },
          })
        end,
        desc = "FFF live grep (fuzzy)",
      },
    },
  },

  {
    "folke/snacks.nvim",
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      input = { enabled = true },
      picker = {
        actions = {
          -- TODO: figure out why toggling to find_files set input to insert mode but live grep to normal mode
          -- TODO: move these actions to fff-snacks plugin
          go_to_live_grep = function(picker)
            picker:close()
            require("fff-snacks").live_grep({
              search = picker.input.filter.search,
            })
          end,
          go_to_find_files = function(picker)
            picker:close()
            require("fff-snacks").find_files({
              search = picker.input.filter.search,
            })
          end,
        },
      },
    },
  },
}
