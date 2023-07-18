---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "tokyodark",
  theme_toggle = { "tokyodark", "one_light" },
  transparency = false,
  hl_override = {
    Comment = { italic = true },
  },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
