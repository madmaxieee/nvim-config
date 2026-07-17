---@type LazySpec
return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    init = function()
      vim.cmd.cabbrev("G", "Neogit")
    end,
    opts = {
      mappings = { status = { ["<space>"] = "Stage" } },
      disable_hint = true,
      graph_style = "unicode",
    },
  },
}
