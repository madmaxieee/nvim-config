-- lifted from https://github.com/folke/tokyonight.nvim/blob/2e1daa1d164ad8cc3e99b44ca68e990888a66038/lua/tokyonight/util.lua

local M = {}

local colorscheme_group = vim.api.nvim_create_augroup("ColorUtils", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = colorscheme_group,
  callback = function()
    local normal_highlight = vim.api.nvim_get_hl(0, { name = "Normal" })
    M.fg = normal_highlight.fg
    M.bg = normal_highlight.bg
  end,
})

---@param c  string|number
local function rgb(c)
  if type(c) == "number" then
    return { c / (256 ^ 2), (c % (256 ^ 2)) / 256, c % 256 }
  else
    c = string.lower(c)
    return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
  end
end

---@param foreground string foreground color
---@param background string background color
---@param alpha number|string number between 0 and 1. 0 results in bg, 1 results in fg
function M.blend(foreground, alpha, background)
  alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
  local bg = rgb(background)
  local fg = rgb(foreground)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

function M.blend_bg(hex, amount, bg)
  return M.blend(hex, amount, bg or M.bg)
end
M.darken = M.blend_bg

function M.blend_fg(hex, amount, fg)
  return M.blend(hex, amount, fg or M.fg)
end
M.lighten = M.blend_fg

return M
