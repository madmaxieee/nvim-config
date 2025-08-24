return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      enabled = true,
      ui_select = true,
      formatters = {
        file = {
          filename_first = true,
          truncate = 40,
          filename_only = false,
          icon_width = 2,
          git_status_hl = true,
        },
      },
    },
  },
}
