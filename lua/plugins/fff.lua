local find_files_opts = {
  win = {
    input = {
      keys = {
        ["<S-Tab>"] = {
          "go_to_live_grep",
          mode = { "n", "i" },
          nowait = true,
        },
      },
    },
  },
}

local live_grep_opts = {
  win = {
    input = {
      keys = {
        ["<S-Tab>"] = {
          "go_to_find_files",
          mode = { "n", "i" },
          nowait = true,
        },
      },
    },
  },
}

local fuzzy_grep_opts = vim.deepcopy(live_grep_opts)
fuzzy_grep_opts.grep_mode = { "fuzzy", "plain", "regex" }

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
    keys = {
      {
        "ff",
        function()
          require("fff-snacks").find_files(find_files_opts)
        end,
        desc = "FFF find files",
      },
      {
        "fw",
        function()
          require("fff-snacks").live_grep(live_grep_opts)
        end,
        desc = "FFF live grep",
      },
      {
        mode = "v",
        "fw",
        function()
          require("fff-snacks").grep_word(live_grep_opts)
        end,
        desc = "FFF grep word",
      },
      {
        "fz",
        function()
          require("fff-snacks").live_grep(fuzzy_grep_opts)
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
          -- TODO: figure out why toggling to find_files set input to insert mode
          -- but live grep to normal mode
          -- TODO: move these actions to fff-snacks plugin
          go_to_live_grep = function(picker)
            picker:close()
            live_grep_opts.search = picker.input.filter.search
            require("fff-snacks").live_grep(live_grep_opts)
          end,
          go_to_find_files = function(picker)
            picker:close()
            find_files_opts.search = picker.input.filter.search
            require("fff-snacks").find_files(find_files_opts)
          end,
        },
      },
    },
  },
}
