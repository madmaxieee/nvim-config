if vim.fn.executable("antigravity") ~= 1 then
  return {}
end

require("agentmux").setup({
  provider = "antigravity",
  providers = {
    antigravity = {
      command = "antigravity",
      tmux_stop_agent = function(pane_id)
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
