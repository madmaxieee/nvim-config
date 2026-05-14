return {
  {
    cond = false,
    "NickvanDyke/opencode.nvim",
  },

  {
    "folke/sidekick.nvim",
    ---@module 'sidekick'
    ---@type sidekick.Config
    opts = {
      cli = {
        tools = {
          ---@type sidekick.cli.Config
          jetski = {
            cmd = { "jetski" },
          },
        },
      },
    },
    keys = {
      {
        "<C-.>",
        mode = { "n", "x" },
        function()
          require("sidekick.cli").focus("jetski")
        end,
        desc = "Toggle coding agent",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
    },
  },
}
