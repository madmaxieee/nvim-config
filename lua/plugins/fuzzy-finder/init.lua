require("plugins.fuzzy-finder.keymaps").setup()

return {
  require "plugins.fuzzy-finder.telescope",
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    keys = {
      {
        "<leader>ff",
        function()
          require("fff").find_files()
        end,
        desc = "Open file picker",
      },
    },
    opts = { prompt = "" },
  },
}
