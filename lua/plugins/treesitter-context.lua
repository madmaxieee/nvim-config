return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufRead", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("treesitter-context").setup {
      enable = true,
      max_lines = 10,
      min_window_height = 30,
      line_numbers = true,
      multiline_threshold = 5,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
      zindex = 20,
      on_attach = nil,
    }
  end,
}
