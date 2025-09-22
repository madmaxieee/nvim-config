return {
  "aaron-p1/match-visual.nvim",
  event = require("utils.events").VisualEnter,
  init = function()
    local color_utils = require "utils.colors"
    color_utils.register_color_update(function()
      local visual_bg = vim.api.nvim_get_hl(0, { name = "Visual" }).bg
      local bg = color_utils.blend_bg(visual_bg, 0.6)
      vim.api.nvim_set_hl(0, "VisualMatch", { bg = bg })
    end)
  end,
  opts = {},
}
