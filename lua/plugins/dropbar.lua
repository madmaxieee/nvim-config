return {
  cond = not vim.g.minimal_mode,
  "Bekaboo/dropbar.nvim",
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      desc = "Set winbar highlight",
      callback = function()
        local color_utils = require "utils.colors"
        local fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg
        local winbar_fg = color_utils.blend_bg(fg, 0.9)
        local winbarnc_fg = color_utils.blend_bg(fg, 0.7)
        vim.api.nvim_set_hl(0, "WinBar", { fg = winbar_fg, bold = true })
        vim.api.nvim_set_hl(0, "WinBarNC", { fg = winbarnc_fg })
      end,
    })
  end,
  opts = {
    sources = {
      path = {
        modified = function(sym)
          return sym:merge {
            icon = "● ",
            name_hl = "DiffAdded",
            icon_hl = "DiffAdded",
          }
        end,
      },
    },
  },
}
