return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  init = function()
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = false,
    })
  end,
  opts = {
    options = {
      show_related = { enabled = false },
    },
  },
}
