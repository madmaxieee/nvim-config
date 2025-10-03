return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  init = function()
    vim.cmd.cabbrev("G", "Neogit")
  end,
  opts = {
    mappings = { status = { ["<space>"] = "Stage" } },
    disable_hint = true,
    graph_style = "unicode",
  },
}
