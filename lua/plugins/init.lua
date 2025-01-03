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
    event = { "BufReadPre", "BufNewFile" },
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
    init = function()
      vim.diagnostic.config { virtual_text = false }
    end,
    config = function()
      require("lsp_lines").setup()
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
    "RRethy/vim-illuminate",
    event = "VeryLazy",
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
    event = "BufReadPre",
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
      local visual_bg = vim.api.nvim_get_hl(0, { name = "Visual" }).bg
      local comment_fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
      vim.api.nvim_set_hl(0, "VisualDimmed", {
        fg = comment_fg,
        bg = visual_bg,
      })
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
    dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
    config = function()
      require("treesj").setup {
        use_default_keymaps = false,
      }
    end,
  },
  {
    "famiu/bufdelete.nvim",
    cmd = "Bd",
    keys = {
      {
        "<leader>bd",
        mode = { "n" },
        function()
          require("bufdelete").bufdelete(0)
        end,
        desc = "delete buffer without disrupting window layout",
      },
    },
    config = function()
      vim.api.nvim_create_user_command("Bd", function()
        require("bufdelete").bufdelete(0)
      end, { desc = "delete buffer without disrupting window layout" })
    end,
  },
}
