return {
  "AckslD/nvim-neoclip.lua",
  dependencies = {
    { "kkharji/sqlite.lua" },
  },
  config = function()
    require("neoclip").setup {
      enable_persistent_history = true,
      keys = {
        telescope = {
          i = {
            paste = "<cr>",
            paste_behind = "<c-k>",
            replay = "<c-q>", -- replay a macro
            delete = "<c-d>", -- delete an entry
            edit = "<c-e>", -- edit an entry
          },
          n = {
            paste = "<cr>",
            paste_behind = "P",
            replay = "q",
            delete = "d",
            edit = "e",
          },
        },
      },
    }
  end,
}
