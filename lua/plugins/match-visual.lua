return {
  "aaron-p1/match-visual.nvim",
  event = require("utils.events").VisualEnter,
  init = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Set match-visual highlight",
      callback = function()
        local color_utils = require "utils.colors"
        local bg = color_utils.blend_bg(vim.api.nvim_get_hl(0, { name = "Visual" }).bg, 0.6)
        vim.api.nvim_set_hl(0, "VisualMatch", { bg = bg })
      end,
    })
  end,
  opts = {},
}
