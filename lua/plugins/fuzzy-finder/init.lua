require("plugins.fuzzy-finder.keymaps").setup()

return {
  require "plugins.fuzzy-finder.telescope",
  require "plugins.fuzzy-finder.snacks-picker",
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    -- scan for faster first load
    event = "VeryLazy",
    -- keys = {
    --   {
    --     "<leader>ff",
    --     function()
    --       require("fff").find_files()
    --     end,
    --     desc = "Open file picker",
    --   },
    -- },
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
