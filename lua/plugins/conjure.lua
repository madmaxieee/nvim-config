return {
  {
    "Olical/conjure",
    ft = { "fennel" },
    init = function()
      vim.g["conjure#mapping#doc_word"] = false
    end,
  },

  {
    "julienvincent/nvim-paredit",
    ft = { "fennel" },
    config = true,
  },

  -- {
  --   "gpanders/nvim-parinfer",
  --   ft = { "fennel" },
  -- },
}
