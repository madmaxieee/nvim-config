require("plugins.fuzzy-finder.keymaps").setup()

return {
  require "plugins.fuzzy-finder.telescope",
  require "plugins.fuzzy-finder.fzf",
  {
    "madmaxieee/fff.nvim",
    branch = "manage-openssl-with-cargo",
    -- "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    keys = {
      {
        "ff",
        function()
          require("fff").find_files()
        end,
        desc = "Open file picker",
      },
    },
    opts = {},
  },
}
