local plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      return require "custom.plugins.configs.treesitter"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/null-ls.nvim",
      config = function()
        require "custom.plugins.configs.null-ls"
      end,
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = function()
      return require "custom.plugins.configs.mason"
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },

  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override_by_extension = {
        ["tpp"] = {
          icon = "",
          name = "tpp",
        },
      },
    },
  },

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
          show = { git = true },
        },
      },
      view = {
        float = {
          enable = true,
          open_win_config = function()
            local HEIGHT_RATIO = 0.7
            local WIDTH_RATIO = 0.4
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            local window_w = screen_w * WIDTH_RATIO
            local window_h = screen_h * HEIGHT_RATIO
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
            return {
              border = "rounded",
              relative = "editor",
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end,
        },
      },
    },
  },

  {
    "NvChad/nvterm",
    opts = {
      terminals = {
        type_opts = {
          float = {
            relative = "editor",
            row = 0.15,
            col = 0.25,
            width = 0.5,
            height = 0.7,
            border = "single",
          },
        },
      },
    },
  },

  {
    "nmac427/guess-indent.nvim",
    cmd = { "GuessIndent" },
    opts = {},
  },

  {
    "mfussenegger/nvim-dap",
    init = function()
      require("core.utils").load_mappings "dap"
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = function()
      return require "custom.plugins.configs.mason-nvim-dap"
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      ---@diagnostic disable-next-line: different-requires
      local dap, dapui = require "dap", require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
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
    event = "BufReadPre",
    dependencies = {
      "kevinhwang91/promise-async",
      "nvim-treesitter/nvim-treesitter",
      "luukvbaal/statuscol.nvim",
    },
    init = function()
      require("core.utils").load_mappings "ufo"
    end,
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
          { text = { "%s" }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          {
            text = { " ", builtin.foldfunc, " " },
            condition = { builtin.not_empty, true, builtin.not_empty },
            click = "v:lua.ScFa",
          },
        },
        ft_ignore = { "terminal", "NvimTree" },
      }
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      highlight = { priority = 10000 },
    },
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
    init = function()
      require("core.utils").load_mappings "Todo Comments"
    end,
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
    "folke/neodev.nvim",
    ft = { "lua" },
    opts = {},
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
      return require "custom.plugins.configs.copilot"
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
    init = function()
      require("core.utils").load_mappings "persistence"
    end,
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

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit" },
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    init = function()
      require("core.utils").load_mappings "LazyGit"
    end,
    config = function()
      require("telescope").load_extension "lazygit"
    end,
  },

  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    init = function()
      require("core.utils").load_mappings "Hardtime"
    end,
    opts = {
      disabled_filetypes = { "terminal", "NvimTree" },
    },
    config = function(_, opts)
      require("hardtime").setup(opts)
      require("hardtime").enable()
    end,
  },

  {
    "utilyre/barbecue.nvim",
    event = "BufEnter",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },

  {
    "SmiteshP/nvim-navic",
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require "custom.plugins.configs.treesitter-textobjects"
    end,
  },

  {
    enabled = false,
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        hover = { enabled = false },
        signature = { enabled = false },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },

  {
    enabled = false,
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup {}
      vim.notify = require "notify"
    end,
  },

  {
    enabled = false,
    "MunifTanjim/nui.nvim",
  },
}

return plugins