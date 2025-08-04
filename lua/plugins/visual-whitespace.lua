return {
  "mcauley-penney/visual-whitespace.nvim",
  event = require("utils.events").VisualEnter,
  init = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Set VisualWhitespace highlight",
      callback = function()
        local visual_bg = vim.api.nvim_get_hl(0, { name = "Visual" }).bg
        local comment_fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
        vim.api.nvim_set_hl(0, "VisualNonText", {
          fg = comment_fg,
          bg = visual_bg,
        })
      end,
    })
  end,
  opts = {},
}
