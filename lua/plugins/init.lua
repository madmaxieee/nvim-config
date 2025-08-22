return {
  { "nvim-lua/plenary.nvim" },

  { "nvim-tree/nvim-web-devicons" },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      if vim.fn.has "mac" == 1 then
        vim.cmd.colorscheme "tokyonight-moon"
      else
        vim.cmd.colorscheme "tokyonight-night"
      end
    end,
  },

  {
    "tpope/vim-sleuth",
    event = { "BufReadPre", "BufNewFile" },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  {
    "NvChad/nvim-colorizer.lua",
    cmd = "ColorizerToggle",
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
    "max397574/better-escape.nvim",
    event = { "InsertEnter", require("utils.events").VisualEnter },
    config = function()
      require("better_escape").setup {
        timeout = vim.o.timeoutlen,
        default_mappings = false,
        mappings = {
          i = { k = { j = "<esc>" } },
          c = { k = { j = "<esc>" } },
          -- HACK: move the cursor back before escaping
          v = { k = { j = "j<esc>" } },
        },
      }
    end,
  },

  {
    "Wansmer/treesj",
    keys = {
      {
        "<leader>s",
        mode = { "n" },
        function()
          require("treesj").toggle()
        end,
        desc = "Toggle split join",
      },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup {
        use_default_keymaps = false,
      }
    end,
  },

  {
    "mtrajano/tssorter.nvim",
    cmd = "TSSort",
    ---@module "tssorter"
    ---@type TssorterOpts
    opts = {},
  },

  {
    "madmaxieee/camelsnek.nvim",
    cmd = {
      "Snek",
      "Screm",
      "Camel",
      "Pascal",
      "Kebab",
    },
    opts = {},
  },
}
