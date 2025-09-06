require("plugins.fuzzy-finder.keymaps").setup()

return {
  require "plugins.fuzzy-finder.telescope",
  require "plugins.fuzzy-finder.snacks-picker",
  {
    -- "dmtrKovalenko/fff.nvim",
    "madmaxieee/fff.nvim",
    lazy = false, -- lazy loaded by design
    build = "cargo build --release",
    opts = {
      prompt = "",
      keymaps = {
        move_up = { "<Up>", "<C-p>", "<C-k>" },
        move_down = { "<Down>", "<C-n>", "<C-j>" },
      },
      layout = {
        prompt_position = "top",
      },
    },
  },
}
