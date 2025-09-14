return {
  "chrisgrieser/nvim-spider",
  keys = {
    {
      "w",
      mode = { "n", "o", "x" },
      function()
        require("spider").motion "w"
      end,
    },
    {
      "e",
      mode = { "n", "o", "x" },
      function()
        require("spider").motion "e"
      end,
    },
    {
      "b",
      mode = { "n", "o", "x" },
      function()
        require("spider").motion "b"
      end,
    },
  },
}
