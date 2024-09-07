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
        mapping = { "kj", "jk" },
        timeout = vim.o.timeoutlen,
      }
    end,
  },
}
