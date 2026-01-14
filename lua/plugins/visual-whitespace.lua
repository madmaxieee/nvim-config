return {
  "mcauley-penney/visual-whitespace.nvim",
  event = require("utils.events").VisualEnter,
  init = function()
    local color_utils = require("utils.colors")
    color_utils.register_color_update(function()
      local visual_bg = vim.api.nvim_get_hl(0, { name = "Visual" }).bg
      local comment_fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
      vim.api.nvim_set_hl(0, "VisualNonText", {
        fg = comment_fg,
        bg = visual_bg,
      })
    end)
  end,
  opts = {},
}
