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
}

return opts
