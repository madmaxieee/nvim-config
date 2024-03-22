return {
  "AckslD/nvim-neoclip.lua",
  dependencies = {
    { "kkharji/sqlite.lua" },
  },
  config = function()
    require("neoclip").setup {
      enable_persistent_history = true,
    }
  end,
}
