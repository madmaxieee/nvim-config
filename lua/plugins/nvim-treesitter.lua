return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufRead", "BufNewFile" },
  cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "lua",
      "python",
      "bash",
      "fish",

      "javascript",
      "typescript",
      "tsx",
      "html",
      "css",

      "c",
      "cpp",
      "rust",
      "go",
      "java",

      "typst",
      "markdown",
      "markdown_inline",
      "json",
      "yaml",
      "kdl",
      "graphql",

      "vim",
      "vimdoc",
      "gitattributes",
      "gitignore",

      "make",
      "cmake",
      "dockerfile",

      "regex",
      "nix",

      "d2",
      "just",
    },

    autotag = {
      enable = true,
    },

    highlight = {
      enable = true,
      use_languagetree = true,
      additional_vim_regex_highlighting = false,
    },

    indent = { enable = true },

    incremental_selection = {
      enable = true,
      keymaps = {
        node_incremental = "v",
        node_decremental = "V",
      },
    },
  },

  config = function(_, opts)
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    ---@diagnostic disable-next-line: inject-field
    parser_config.d2 = {
      install_info = {
        url = "https://codeberg.org/p8i/tree-sitter-d2.git",
        revision = "main",
        files = { "src/parser.c", "src/scanner.c" },
      },
      filetype = "d2",
    }
    vim.treesitter.language.register("markdown", "mdx")
    require("nvim-treesitter.configs").setup(opts)
  end,
}
