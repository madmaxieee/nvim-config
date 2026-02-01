return {
  cond = false,
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
  init = function()
    ---@module 'opencode'
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      provider = { enabled = "tmux" },
    }
  end,
  keys = {
    {
      "<leader>aa",
      function()
        -- create tmux split if opencode is not running
        require("opencode").prompt("")
        require("opencode").ask("@cursor: ")
      end,
      mode = "n",
      desc = "Ask about this",
    },
    {
      "<leader>aa",
      function()
        -- create tmux split if opencode is not running
        require("opencode").prompt("")
        require("opencode").ask("@selection: ")
      end,
      mode = "v",
      desc = "Ask about selection",
    },
    {
      "<leader>ap",
      function()
        require("opencode").prompt("@buffer", { append = true })
      end,
      mode = "n",
      desc = "Ask about buffer",
    },
    {
      "<leader>ap",
      function()
        require("opencode").prompt("@selection", { append = true })
      end,
      mode = "v",
      desc = "Add selection to prompt",
    },
    {
      "<leader>ae",
      function()
        require("opencode").prompt("Explain @cursor and its context")
      end,
      mode = "n",
      desc = "Explain this code",
    },
    {
      "<leader>ae",
      function()
        require("opencode").prompt("Explain @selection and its context")
      end,
      mode = "v",
      desc = "Explain this code",
    },
    {
      "<leader>an",
      function()
        require("opencode").command("session_new")
      end,
      mode = "n",
      desc = "New session",
    },
    {
      "<leader>as",
      function()
        require("opencode").select()
      end,
      mode = { "n", "v" },
      desc = "Select prompt",
    },
  },
}
