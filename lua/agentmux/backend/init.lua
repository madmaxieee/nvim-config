local M = {}

local backends = {
  tmux = require("agentmux.backend.tmux"),
  herdr = require("agentmux.backend.herdr"),
}

function M.detect()
  if vim.env.HERDR_ENV == "1" or vim.env.HERDR_PANE_ID then
    return "herdr"
  end

  return "tmux"
end

function M.get(name)
  if not name or name == "auto" then
    name = M.detect()
  end

  return backends[name] or backends.tmux
end

return M
