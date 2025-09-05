return {
  {
    "nvim-mini/mini.surround",
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
