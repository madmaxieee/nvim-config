return {
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
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
