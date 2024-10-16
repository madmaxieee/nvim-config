local color_utils = require "utils.colors"

local colorscheme_group = vim.api.nvim_create_augroup("CreateCustomHighlight", { clear = true })

local function update_fg_bg()
  local normal_highlight = vim.api.nvim_get_hl(0, { name = "Normal" })
  color_utils.fg = normal_highlight.fg
  color_utils.bg = normal_highlight.bg
end

local function setup_visual_dimmed()
  local visual_bg = vim.api.nvim_get_hl(0, { name = "Visual" }).bg
  local comment_fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
  vim.api.nvim_set_hl(0, "VisualDimmed", {
    fg = comment_fg,
    bg = visual_bg,
  })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = colorscheme_group,
  callback = function()
    update_fg_bg()
    setup_visual_dimmed()
  end,
})
