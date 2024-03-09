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
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            -- You can optionally set descriptions to the mappings (used in the desc parameter of
            -- nvim_buf_set_keymap) which plugins like which-key display
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
            -- You can also use captures from other query groups like `locals.scm`
            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
          },
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@function.inner"] = "V",
            ["@class.inner"] = "V",
            ["@class.outer"] = "V",
          },
          include_surrounding_whitespace = true,
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
            ["]o"] = "@loop.*",
            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[["] = "@class.outer",
            ["[o"] = "@loop.*",
            ["[s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["[z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = { enable = false },
        lsp_interop = { enable = false },
      },
    }
  end,
}
