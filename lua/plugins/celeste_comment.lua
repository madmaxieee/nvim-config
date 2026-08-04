return {
  "celeste3z/celeste_comment.nvim",
  lazy = false,
  opts = {
    ignore_empty_lines = "mixed",
    mappings = {
      line_toggle = { "gc", "<leader>/" },
      line_toggle_cur = { "gcc", "<leader>/" },
      line_toggle_visual = { "gc", "<leader>/" },
      auto_textobject = "ic",
      uncomment_auto = "gC",
    },
  },
}
