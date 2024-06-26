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
    },

    autotag = {
      enable = true,
    },

    highlight = {
      enable = true,
      use_languagetree = true,
    },

    additional_vim_regex_highlighting = false,

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
    require("nvim-treesitter.configs").setup(opts)
    vim.treesitter.language.register("markdown", "mdx")
  end,
}
