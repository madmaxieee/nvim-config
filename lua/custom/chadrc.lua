---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "one_light" },
  transparency = false,
  tabufline = {
    show_numbers = true,
  },
  hl_override = {
    Comment = {
      italic = true,
    },
    IndentBlanklineContextChar = {
      fg = "purple",
    },
    IndentBlanklineContextStart = {
      sp = "purple",
      bg = "NONE",
      underline = true,
    },
    IndentBlanklineChar = {
      fg = "light_grey",
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
    DiagnosticUnderlineError = {
      undercurl = true,
      fg = "red",
    },
    DiagnosticUnderlineWarn = {
      undercurl = true,
      fg = "orange",
    },
  },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
