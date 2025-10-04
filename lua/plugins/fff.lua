return {
  {
    "madmaxieee/fff.nvim",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false, -- make fff initialize on startup
  },

  {
    "madmaxieee/fff-snacks.nvim",
    cmd = "FFFSnacks",
    keys = {
      {
        "<leader>ff",
        "<cmd> FFFSnacks <cr>",
        desc = "FFF",
      },
    },
    config = true,
  },
}
