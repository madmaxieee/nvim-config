return {
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      if vim.fn.has "mac" == 1 then
        vim.cmd.colorscheme "tokyonight-moon"
      else
        vim.cmd.colorscheme "tokyonight-night"
      end
    end,
  },
  {
    "tpope/vim-sleuth",
    event = { "BufRead", "BufNewFile" },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "folke/neodev.nvim",
    ft = "lua",
    opts = {},
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        insert_only = false,
      },
    },
  },
  {
    -- the original repo is broken, use my mirror
    -- "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    "madmaxieee/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config { virtual_text = false }
    end,
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      {
        "<leader>z",
        mode = "n",
        "<cmd>ZenMode<CR>",
        { desc = "Toggle zen mode" },
      },
    },
    opts = {},
  },
  {
    "NvChad/nvim-colorizer.lua",
    ft = {
      "html",
      "css",
      "scss",
      "typescript",
      "typescriptreact",
      "javascript",
      "javascriptreact",
    },
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
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
    },
    opts = {
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.wrap = false
          vim.opt_local.buflisted = false
          local map_repeatable_pair = require("utils").map_repeatable_pair
          map_repeatable_pair({ "n", "x", "o" }, {
            next = {
              "]h",
              function()
                vim.cmd.normal { "]c", bang = true }
              end,
              { desc = "Next hunk", buffer = bufnr },
            },
            prev = {
              "[h",
              function()
                vim.cmd.normal { "[c", bang = true }
              end,
              { desc = "Previous hunk", buffer = bufnr },
            },
          })
        end,
      },
    },
  },
  {
    "RRethy/vim-illuminate",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("illuminate").configure {
        providers = {
          "lsp",
          "treesitter",
          "regex",
        },
      }
    end,
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup {
        timeout = vim.o.timeoutlen,
        default_mappings = false,
        mappings = {
          i = { k = { j = "<esc>" } },
          c = { k = { j = "<esc>" } },
        },
      }
    end,
  },
  {
    "LunarVim/bigfile.nvim",
    opts = {
      filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
      pattern = { "*" }, -- autocmd pattern or function see <### Overriding the detection of big files>
      features = { -- features to disable
        "indent_blankline",
        "illuminate",
        "lsp",
        "treesitter",
        "syntax",
        "matchparen",
        "vimopts",
        "filetype",
      },
    },
    config = true,
  },
  {
    "mcauley-penney/visual-whitespace.nvim",
    event = require("utils.events").VisualEnter,
    config = function()
      require("visual-whitespace").setup { highlight = { link = "VisualDimmed" } }
    end,
  },
  {
    "aaron-p1/match-visual.nvim",
    event = require("utils.events").VisualEnter,
    config = function()
      local color_utils = require "utils.colors"
      local bg = color_utils.blend_bg(vim.api.nvim_get_hl(0, { name = "Visual" }).bg, 0.6)
      vim.api.nvim_set_hl(0, "VisualMatch", { bg = bg })
      require("match-visual").setup {}
    end,
  },
  {
    "cbochs/grapple.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Grapple",
    opts = {
      icons = true,
      quick_select = "1234567890",
    },
    keys = {
      { "<leader>a", "<cmd>Grapple toggle_tags<cr>", desc = "Toggle tags menu" },
      { "<leader>m", "<cmd>Grapple toggle<cr>", desc = "Toggle tag" },
      { "<leader>1", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
      { "<leader>2", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
      { "<leader>3", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
      { "<leader>4", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },
      { "<A-f>", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
      { "<A-d>", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
      { "<A-s>", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
      { "<A-a>", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },
      { "L", "<cmd>Grapple cycle_tags prev<cr>", desc = "Go to previous tag" },
      { "H", "<cmd>Grapple cycle_tags next<cr>", desc = "Go to next tag" },
    },
  },
}
