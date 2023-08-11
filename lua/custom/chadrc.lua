---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "one_light" },
  transparency = false,
  hl_override = {
    Comment = {
      italic = true,
    },
  },
  hl_add = {
    FlashBackdrop = {
      fg = "light_grey",
    },
    FlashCurrent = {
      fg = "black2",
      bg = "baby_pink",
    },
    FlashLabel = {
      fg = "black2",
      bg = "orange",
    },
    FlashMatch = {
      fg = "black2",
      bg = "sun",
    },
  },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
