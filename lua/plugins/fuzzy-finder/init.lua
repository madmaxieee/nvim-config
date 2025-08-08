require("plugins.fuzzy-finder.keymaps").setup()

return {
  require "plugins.fuzzy-finder.telescope",
  require "plugins.fuzzy-finder.fzf",
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    keys = {
      {
        "<leader>ff",
        function()
          require("fff").find_files()
          require("keymap-benchmark").record("n", "<leader>ff")
        end,
        desc = "Open file picker",
      },
    },
    opts = { prompt = "" },
  },
}
