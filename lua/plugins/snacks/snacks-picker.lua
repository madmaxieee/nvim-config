return {
  "folke/snacks.nvim",
  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    picker = {
      enabled = true,
      ui_select = true,
      formatters = {
        file = { filename_first = true },
      },
      previewers = {
        file = {
          max_size = 10 * 1024 * 1024, -- 10MB
        },
      },
      win = {
        preview = {
          wo = {
            wrap = false,
          },
        },
      },
    },
  },

  keys = {
    {
      "<leader>fw",
      mode = "n",
      function()
        require("plugins.snacks.multi-grep").multi_grep()
      end,
      desc = "Live grep",
    },

    {
      "<leader>fw",
      mode = "v",
      function()
        require("snacks").picker.grep_word()
      end,
      desc = "Grep string",
    },

    {
      "<leader>fg",
      function()
        require("snacks").picker.git_status()
      end,
      desc = "Git status",
    },

    {
      "<leader>fa",
      function()
        require("snacks").picker.files {
          cmd = "fd",
          args = {
            "--color=never",
            "--hidden",
            "--type",
            "f",
            "--type",
            "l",
            "--no-ignore",
            "--exclude",
            ".git",
          },
        }
      end,
      desc = "Find all files",
    },

    {
      "<leader>fb",
      function()
        require("snacks").picker.buffers()
      end,
      desc = "Find buffers",
    },

    {
      "<leader>fj",
      function()
        require("snacks").picker.jumps()
      end,
      desc = "Find jumps",
    },

    {
      "<leader>fh",
      function()
        require("snacks").picker.help()
      end,
      desc = "Find help",
    },

    {
      "<leader>fz",
      function()
        require("snacks").picker.lines()
      end,
      desc = "Find lines",
    },

    {
      "<leader>fr",
      function()
        require("snacks").picker.resume()
      end,
      desc = "Find recent files",
    },

    {
      "<leader>cm",
      function()
        require("snacks").picker.git_log()
      end,
      desc = "Git commits",
    },

    {
      "<leader>gg",
      function()
        require("snacks").picker.git_files()
      end,
      desc = "Find git files",
    },

    {
      "<leader>fd",
      function()
        require("snacks").picker.diagnostics()
      end,
      desc = "Find diagnostics",
    },

    {
      "<leader>fs",
      function()
        require("snacks").picker.lsp_symbols()
      end,
      desc = "Find document symbols",
    },

    {
      "<leader>ws",
      function()
        require("snacks").picker.lsp_workspace_symbols()
      end,
      desc = "Find workspace symbols",
    },

    {
      "<leader>fc",
      function()
        require("snacks").picker.command_history()
      end,
      desc = "Find commands",
    },

    {
      "<leader>fu",
      function()
        require("snacks").picker.undo()
      end,
      desc = "Find undo history",
    },
  },
}
