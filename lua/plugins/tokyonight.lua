return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    if vim.fn.has("mac") == 1 then
      vim.cmd.colorscheme("tokyonight-moon")
    else
      vim.cmd.colorscheme("tokyonight-night")
    end
  end,
}
