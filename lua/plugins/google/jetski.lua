require("agentmux").setup({
  provider = "jetski",
  providers = {
    jetski = {
      command = "jetski",
      stop_agent = function(pane_id)
        -- stylua: ignore
        vim.system({
          "tmux", "send-keys", "-t", pane_id,
          -- clear prompt then exit opencode
          "C-c", "C-c",
        })
      end,
    },
  },
})

return {
  {
    cond = false,
    "NickvanDyke/opencode.nvim",
  },
}
