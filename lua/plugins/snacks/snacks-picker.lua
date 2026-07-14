return {
  "folke/snacks.nvim",
  dependencies = { "madmaxieee/jj-diff.nvim" },
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
    -- {
    --   "<leader>fw",
    --   mode = "n",
    --   function()
    --     require("plugins.snacks.multi-grep").multi_grep()
    --   end,
    --   desc = "Live grep",
    -- },

    -- {
    --   "<leader>fw",
    --   mode = "x",
    --   function()
    --     require("snacks").picker.grep_word()
    --   end,
    --   desc = "Grep string",
    -- },

    {
      "<leader>fg",
      function()
        if require("jj-diff").find_root() ~= nil then
          require("jj-diff.snacks").status()
        else
          require("snacks").picker.git_status()
        end
      end,
      desc = "jj or git status",
    },

    {
      "<leader>fd",
      function()
        if require("jj-diff").find_root() ~= nil then
          require("jj-diff.snacks").diff()
        else
          require("snacks").picker.git_diff()
        end
      end,
      desc = "jj or git diff",
    },

    {
      "<leader>fa",
      function()
        require("snacks").picker.files({
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
        })
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
      "<leader>fl",
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
      "<leader>fs",
      function()
        require("snacks").picker.lsp_symbols()
      end,
      desc = "Find document symbols",
    },

    {
      "<leader>fS",
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
