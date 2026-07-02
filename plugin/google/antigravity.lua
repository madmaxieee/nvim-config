if vim.fn.executable("agy") ~= 1 then
  return {}
end

require("agentmux").setup({
  provider = "agy",
  providers = {
    agy = {
      command = "agy",
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
