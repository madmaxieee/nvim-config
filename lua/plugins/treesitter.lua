local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.typst = {
  install_info = {
    -- local path or git repo
    url = vim.fn.stdpath "config" .. "/tree-sitter-typst",
    -- note that some parsers also require src/scanner.c or src/scanner.cc
    files = { "src/parser.c", "src/scanner.c" },
    -- optional entries:
    -- default branch in case of git repo if different from master
    branch = "master",
    -- if stand-alone parser without npm dependencies
    generate_requires_npm = false,
    -- if folder contains pre-generated src/parser.c
    requires_generate_from_grammar = false,
  },
  filetype = "typst",
}

return {
  "nvim-treesitter/nvim-treesitter",
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

      "markdown",
      "json",
      "yaml",
      "kdl",
      "make",
      "cmake",
      "gitattributes",
      "gitignore",
      "dockerfile",
      "graphql",

      "c",
      "cpp",
      "rust",
      "go",
    },

    autotag = {
      enable = true,
    },

    additional_vim_regex_highlighting = false,

    indent = { enable = true },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
