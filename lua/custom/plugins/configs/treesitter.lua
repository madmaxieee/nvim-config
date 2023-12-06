local opts = {
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

  highlight = {
    enable = true,
  },

  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = "o",
      toggle_hl_groups = "i",
      toggle_injected_languages = "t",
      toggle_anonymous_nodes = "a",
      toggle_language_display = "I",
      focus_language = "f",
      unfocus_language = "F",
      update = "R",
      goto_node = "<cr>",
      show_help = "?",
    },
  },
}

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.typst = {
  install_info = {
    url = vim.fn.stdpath "config" .. "/tree-sitter-typst", -- local path or git repo
    files = { "src/parser.c", "src/scanner.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = "master", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
  filetype = "typst", -- if filetype does not match the parser name
}

return opts
