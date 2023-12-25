local plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    -- dependencies = { "nvim-treesitter/playground" },
    opts = function()
      return require "custom.plugins.configs.treesitter"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- "jose-elias-alvarez/null-ls.nvim",
      "nvimtools/none-ls.nvim",
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
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = {
        custom = { "node_modules", ".git" },
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
      view = {
        float = {
          enable = true,
          open_win_config = function()
            local HEIGHT_RATIO = 0.7
            local WIDTH_RATIO = 0.4
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get()
            local window_w = screen_w * WIDTH_RATIO
            local window_h = screen_h * HEIGHT_RATIO
            local window_w_int = math.ceil(window_w)
            local window_h_int = math.ceil(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = (vim.opt.lines:get() - window_h) / 2
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
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
    opts = {
      defaults = {
        file_ignore_patterns = { "^.git$" },
        mappings = {
          i = {
            ["<c-t>"] = function(prompt_bufnr)
              require "telescope.actions"
              local trouble = require "trouble.providers.telescope"
              trouble.open_with_trouble(prompt_bufnr)
            end,
          },
          n = {
            ["<c-t>"] = function(prompt_bufnr)
              require "telescope.actions"
              local trouble = require "trouble.providers.telescope"
              trouble.open_with_trouble(prompt_bufnr)
            end,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    tag = "v2.0.0",
  },

  {
    "NvChad/nvterm",
    opts = {
      terminals = {
        type_opts = {
          float = {
            relative = "editor",
            row = 0.15,
            col = 0.2,
            width = 0.6,
            height = 0.7,
            border = "rounded",
          },
        },
      },
    },
  },

  {
    "nmac427/guess-indent.nvim",
    cmd = { "GuessIndent" },
    init = function()
      vim.api.nvim_create_autocmd({ "BufReadPost" }, {
        group = vim.api.nvim_create_augroup("guess-indent", { clear = true }),
        callback = function()
          vim.cmd "silent GuessIndent"
        end,
      })
    end,
    config = function()
      require("guess-indent").setup {}
    end,
  },

  {
    "mfussenegger/nvim-dap",
    init = function()
      require("core.utils").load_mappings "dap"
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    opts = function()
      return require "custom.plugins.configs.mason-nvim-dap"
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "jay-babu/mason-nvim-dap.nvim" },
    config = function()
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
    event = "VeryLazy",
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
    dependencies = { "kevinhwang91/promise-async", "nvim-treesitter/nvim-treesitter", "luukvbaal/statuscol.nvim" },
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

  { "kevinhwang91/promise-async" },

  {
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require "statuscol.builtin"
      require("statuscol").setup {
        relculright = true,
        segments = {
          {
            text = { "%s" },
            click = "v:lua.ScSa",
          },
          {
            text = { builtin.lnumfunc },
            click = "v:lua.ScLa",
          },
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
      highlight = {
        priority = 10000,
      },
      modes = {
        char = {
          enabled = false,
        },
      },
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
    dependencies = { "kkharji/sqlite.lua", "nvim-telescope/telescope.nvim" },
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

  { "kkharji/sqlite.lua" },

  {
    "folke/todo-comments.nvim",
    event = "BufReadPre",
    cmd = { "TodoQuickFix", "TodoLocList", "TodoTrouble", "TodoTelescope" },
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
        TODO = {
          icon = " ",
          color = "info",
        },
        HACK = {
          icon = " ",
          color = "warning",
        },
        WARN = {
          icon = " ",
          color = "warning",
          alt = { "WARNING", "XXX" },
        },
        PERF = {
          icon = "󰅒",
          alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
        },
        NOTE = {
          icon = "",
          color = "hint",
          alt = { "INFO" },
        },
        TEST = {
          icon = "⏲ ",
          color = "test",
          alt = { "TESTING", "PASSED", "FAILED" },
        },
      },
      search = {
        command = "rg",
        args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      context_char = "▏",
      show_first_indent_level = true,
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
    enabled = false,
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPre",
    opts = {
      multiline_threshold = 10, -- Maximum number of lines to collapse for a single context line
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
    enabled = false,
    "kaarmu/typst.vim",
    ft = "typst",
    init = function()
      vim.g.typst_pdf_viewer = "skim"
    end,
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
    config = function(_, opts)
      require("core.utils").load_mappings "trouble"
      require("trouble").setup(opts)
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit" },
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    init = function()
      require("core.utils").load_mappings "LazyGit"
    end,
    config = function()
      require("telescope").load_extension "lazygit"
    end,
  },

  {
    -- enabled = false,
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
    lazy = false,
    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("barbecue").setup {}
    end,
  },

  { "SmiteshP/nvim-navic" },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require "custom.plugins.configs.treesitter-textobjects"
    end,
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        keymaps = {
          insert = "<C-g>z",
          insert_line = "<C-g>Z",
          normal = "yz",
          normal_cur = "yzz",
          normal_line = "yZ",
          normal_cur_line = "yZZ",
          visual = "Z",
          visual_line = "gZ",
          delete = "dz",
          change = "cz",
        },
      }
    end,
  },

  {
    "ivanjermakov/troublesum.nvim",
    event = "LspAttach",
    config = function()
      require("troublesum").setup {
        enabled = true,
        autocmd = true,
        severity_format = { " ", " ", "", " " },
        severity_highlight = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" },
      }
    end,
  },

  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config {
        virtual_text = false,
      }
    end,
  },

  {
    enabled = false,
    "madmaxieee/code-shot.nvim",
    cmd = { "CodeShot" },
    config = function()
      require("code-shot").setup {
        to_clipboard = true,
        ---@return string output file path
        output = function()
          local buf_name = vim.api.nvim_buf_get_name(0)
          return string.match(buf_name, "([^/^%.]+)[^/]*$") .. ".png"
        end,
        ---@return string[]
        -- select_area: {s_start: {row: number, col: number}, s_end: {row: number, col: number}} | nil
        options = function(select_area)
          if not select_area then
            return {}
          end
          return {
            "--line-offset",
            select_area.s_start.row,
            "--theme",
            "Dracula",
          }
        end,
      }
    end,
  },

  {
    "mickael-menu/zk-nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    config = function()
      require("zk").setup {
        picker = "telescope",
        lsp = {
          -- `config` is passed to `vim.lsp.start_client(config)`
          config = {
            cmd = { "zk", "lsp" },
            name = "zk",
          },
          auto_attach = {
            enabled = true,
            filetypes = { "markdown" },
          },
        },
      }
    end,
  },

  {
    "folke/noice.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
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
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup {}
      vim.notify = require "notify"
    end,
  },

  { "MunifTanjim/nui.nvim" },
}

return plugins
