---@type LazySpec
return {
  {
    "NicholasZolton/neojj",
    version = "^1.0.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "folke/snacks.nvim",
    },
    cmd = "Neojj",
    init = function()
      vim.cmd.cabbrev("J", "Neojj")
    end,
  },
}
