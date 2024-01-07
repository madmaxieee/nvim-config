return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  keys = {
    "]m",
    "]]",
    "]o",
    "]s",
    "]z",
    "]M",
    "][",
    "[m",
    "[[",
    "[o",
    "[s",
    "[z",
    "[M",
    "[]",
  },
  dependencies = {
    -- "nvim-treesitter/nvim-treesitter"
    "madmaxieee/nvim-treesitter", -- use my own fork for typst support
  },
  config = function()
    require("nvim-treesitter.configs").setup {
      textobjects = {
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
            ["]o"] = "@loop.*",
            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
            ["[o"] = "@loop.*",
            ["[s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["[z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = { enable = false },
        lsp_interop = { enable = false },
      },
    }
  end,
}
