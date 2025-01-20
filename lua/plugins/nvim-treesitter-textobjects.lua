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
      ["aa"] = { query = "@parameter.outer" },
      ["ia"] = { query = "@parameter.inner" },
      ["af"] = { query = "@function.outer" },
      ["if"] = { query = "@function.inner" },
      ["ac"] = { query = "@class.outer" },
      ["ic"] = { query = "@class.inner" },
      ["as"] = {
        query = "@local.scope",
        query_group = "locals",
      },
    }
    for keymap, query in pairs(select_keymaps) do
      query.query_group = query.query_group or "textobjects"
      map( --
        { "x", "o" },
        keymap,
        function()
          select.select_textobject(query.query, query.query_group, "v")
        end,
        { desc = "select " .. query.query }
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
        position = "end",
        next_key = "]F",
        prev_key = "[F",
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
      local next_fn, prev_fn
      if keymap.position == "end" then
        next_fn = move.goto_next_end
        prev_fn = move.goto_previous_end
      else
        next_fn = move.goto_next_start
        prev_fn = move.goto_previous_start
      end
      map_repeatable_pair({ "n", "x", "o" }, {
        next = {
          keymap.next_key,
          function()
            next_fn(keymap.query, keymap.query_group)
          end,
          { desc = "next " .. keymap.query },
        },
        prev = {
          keymap.prev_key,
          function()
            prev_fn(keymap.query, keymap.query_group)
          end,
          { desc = "prev " .. keymap.query },
        },
      })
    end
  end,
}
