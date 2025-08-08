return {
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = { modes = { insert = true, command = true, terminal = false } },
    config = function(_, opts)
      require("mini.pairs").setup(opts)
      vim.keymap.set({ "i", "c" }, "<BS>", MiniPairs.bs, { expr = true, replace_keycodes = false })
      vim.keymap.set({ "i", "c" }, "<CR>", MiniPairs.cr, { expr = true, replace_keycodes = false })
    end,
  },

  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "yz", -- Add surrounding in Normal and Visual modes
        delete = "dz", -- Delete surrounding
        find = "", -- Find surrounding (to the right)
        find_left = "", -- Find surrounding (to the left)
        highlight = "", -- Highlight surrounding
        replace = "cz", -- Replace surrounding
        update_n_lines = "", -- Update `n_lines`

        suffix_last = "", -- Suffix to search with "prev" method
        suffix_next = "", -- Suffix to search with "next" method
      },
      n_lines = 20,
    },
  },
}
