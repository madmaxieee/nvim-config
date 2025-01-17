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
    bar = {
      enable = function(buf, win, _)
        if
          not vim.api.nvim_buf_is_valid(buf)
          or not vim.api.nvim_win_is_valid(win)
          or vim.fn.win_gettype(win) ~= ""
          or vim.wo[win].winbar ~= ""
          or vim.bo[buf].ft == "help"
          or vim.bo[buf].ft == "noice"
        then
          return false
        end
        local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
        if stat and stat.size > 1024 * 1024 then
          return false
        end
        return true
      end,
    },
  },
}
