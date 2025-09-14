return {
  "max397574/better-escape.nvim",
  event = { "InsertEnter", require("utils.events").VisualEnter },
  config = function()
    require("better_escape").setup {
      timeout = vim.o.timeoutlen,
      default_mappings = false,
      mappings = {
        i = { k = { j = "<esc>" } },
        c = { k = { j = "<esc>" } },
        -- HACK: move the cursor back before escaping
        v = { k = { j = "j<esc>" } },
      },
    }
  end,
}
