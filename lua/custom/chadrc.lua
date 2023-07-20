---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "nightowl",
  theme_toggle = { "nightowl", "one_light" },
  transparency = false,
  hl_override = {
    Comment = { italic = true },
  },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
