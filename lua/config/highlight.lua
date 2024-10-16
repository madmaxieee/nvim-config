local colorscheme_group = vim.api.nvim_create_augroup("CreateCustomHighlight", { clear = true })

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
    setup_visual_dimmed()
  end,
})
