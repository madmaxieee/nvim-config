return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup {
      textobjects = {
        select = {
          enable = true,
          lookahead = false,
          include_surrounding_whitespace = false,
        },
        move = {
          enable = true,
          set_jumps = true,
        },
        swap = { enable = false },
        lsp_interop = { enable = false },
      },
    }

    local utils = require "utils"

    local map = utils.safe_keymap_set
    local select = require "nvim-treesitter.textobjects.select"
    local select_keymaps = {
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
    }
    for keymap, query in pairs(select_keymaps) do
      map( --
        { "x", "o" },
        keymap,
        function()
          select.select_textobject(query, "textobjects", "v")
        end,
        { desc = "select " .. query }
      )
    end

    local map_repeatable_pair = utils.map_repeatable_pair
    local move = require "nvim-treesitter.textobjects.move"
    local move_keymaps = {
      {
        next_key = "]f",
        prev_key = "[f",
        query = "@function.outer",
      },
      {
        next_key = "]C",
        prev_key = "[C",
        query = "@class.outer",
      },
      {
        next_key = "]z",
        prev_key = "[z",
        query = "@fold",
        query_group = "folds",
      },
    }
    for _, keymap in ipairs(move_keymaps) do
      keymap.query_group = keymap.query_group or "textobjects"
      map_repeatable_pair({ "n", "x", "o" }, {
        next = {
          keymap.next_key,
          function()
            move.goto_next_start(keymap.query, keymap.query_group)
          end,
          { desc = "next " .. keymap.query },
        },
        prev = {
          keymap.prev_key,
          function()
            move.goto_previous_start(keymap.query, keymap.query_group)
          end,
          { desc = "prev " .. keymap.query },
        },
      })
    end
  end,
}
