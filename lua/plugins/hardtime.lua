return {
  "m4xshen/hardtime.nvim",
  event = "VeryLazy",
  opts = {
    disabled_filetypes = { "qf", "netrw", "neo-tree", "lazy", "mason", "oil" },
  },
  config = function(_, opts)
    require("hardtime").setup(opts)
    require("hardtime").enable()
  end,
}
