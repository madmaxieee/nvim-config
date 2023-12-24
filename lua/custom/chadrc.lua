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
  statusline = {
    overriden_modules = function(modules)
      table.insert(
        modules,
        2,
        (function()
          local recording_register = vim.fn.reg_recording()
          local sep_r = ""
          if recording_register == "" then
            return ""
          else
            return "%#St_ReplaceMode#"
              .. sep_r
              .. " Recording @"
              .. recording_register
              .. " %#St_ReplaceModeSep#"
              .. sep_r
              .. "%#St_EmptySpace#"
              .. sep_r
          end
        end)()
      )
    end,
  },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
