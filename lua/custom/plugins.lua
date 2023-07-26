local plugins = {
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = {
        custom = {
          "node_modules",
          ".git",
        },
      },
      diagnostics = {
        enable = false,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      git = {
        timeout = 500,
        enable = true,
      },
      renderer = {
        icons = {
          show = {
            git = true,
          },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      return require "custom.configs.treesitter"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/null-ls.nvim",
      config = function()
        require "custom.configs.null-ls"
      end,
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },

  {
    enabled = false,
    "mfussenegger/nvim-dap",
  },

  {
    "williamboman/mason.nvim",
    opts = function()
      return require "custom.configs.mason"
    end,
  },

  {
    "akinsho/git-conflict.nvim",
    cmd = {
      "GitConflictChooseOurs",
      "GitConflictChooseTheirs",
      "GitConflictChooseBoth",
      "GitConflictChooseNone",
      "GitConflictNextConflict",
      "GitConflictPrevConflict",
      "GitConflictListQf",
    },
    init = function()
      vim.api.nvim_create_user_command("Gcco", "GitConflictChooseOurs", {})
      vim.api.nvim_create_user_command("Gcct", "GitConflictChooseTheirs", {})
      vim.api.nvim_create_user_command("Gccb", "GitConflictChooseBoth", {})
      vim.api.nvim_create_user_command("Gcn", "GitConflictNextConflict", {})
      vim.api.nvim_create_user_command("Gcp", "GitConflictPrevConflict", {})
      vim.api.nvim_create_user_command("Gcl", "GitConflictListQf", {})
    end,
    config = true,
  },

  {
    "kevinhwang91/nvim-ufo",
    event = "UIEnter",
    dependencies = {
      "kevinhwang91/promise-async",
      "nvim-treesitter/nvim-treesitter",
      "luukvbaal/statuscol.nvim",
    },
    opts = {
      ---@diagnostic disable-next-line: unused-local
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    },
    config = true,
  },

  {
    "kevinhwang91/promise-async",
  },

  {
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require "statuscol.builtin"
      require("statuscol").setup {
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { "%s" }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        },
        ft_ignore = { "terminal", "NvimTree" },
      }
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Flash Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },

  {
    "AckslD/nvim-neoclip.lua",
    event = "VeryLazy",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("neoclip").setup {
        keys = {
          telescope = {
            i = {
              paste = "<cr>",
              paste_behind = "<c-k>",
              replay = "<c-q>", -- replay a macro
              delete = "<c-d>", -- delete an entry
              edit = "<c-e>", -- edit an entry
            },
            n = {
              paste = "<cr>",
              paste_behind = "P",
              replay = "q",
              delete = "d",
              edit = "e",
            },
          },
        },
      }
      require("telescope").load_extension "neoclip"
    end,
  },

  {
    "kkharji/sqlite.lua",
  },

  {
    "folke/todo-comments.nvim",
    event = "BufReadPre",
    cmd = {
      "TodoQuickFix",
      "TodoLocList",
      "TodoTrouble",
      "TodoTelescope",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "󰅒", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = "", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      },
    },
  },

  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = false,
        tailwind = true,
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPre",
    opts = {
      multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
    },
  },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = function()
      return require "custom.configs.copilot"
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local Util = require "lazyvim.util"
      local colors = {
        [""] = Util.fg "Special",
        ["Normal"] = Util.fg "Special",
        ["Warning"] = Util.fg "DiagnosticError",
        ["InProgress"] = Util.fg "DiagnosticWarn",
      }
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local icon = require("lazyvim.config").icons.kinds.Copilot
          local status = require("copilot.api").status.data
          return icon .. (status.message or "")
        end,
        cond = function()
          local ok, clients = pcall(vim.lsp.get_active_clients, { name = "copilot", bufnr = 0 })
          return ok and #clients > 0
        end,
        color = function()
          if not package.loaded["copilot"] then
            return
          end
          local status = require("copilot.api").status.data
          return colors[status.status] or colors[""]
        end,
      })
    end,
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath "state" .. "/sessions/"), -- directory where session files are saved
      options = { "buffers", "curdir", "tabpages", "winsize" }, -- sessionoptions used for saving
      pre_save = nil, -- a function to call before saving the session
    },
    config = true,
  },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
  },

  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "edluffy/hologram.nvim",
    ft = { "markdown" },
    opts = {
      auto_display = true,
    },
  },
}

return plugins
