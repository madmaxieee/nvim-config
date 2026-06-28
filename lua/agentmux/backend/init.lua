---@alias AgentMuxBackendName "tmux" | "herdr"

---@class AgentMuxState
---@field backend AgentMuxBackendName?
---@field data table?

---@class AgentMuxBackend
---@field get_pane_id fun(state: AgentMuxState): string?
---@field start fun(state: AgentMuxState, cfg: AgentMuxConfig)
---@field stop fun(state: AgentMuxState, cfg: AgentMuxConfig, pane_id: string)
---@field focus fun(state: AgentMuxState, pane_id: string)
---@field send_keys fun(state: AgentMuxState, pane_id: string, keys: string[])
---@field send_text? fun(state: AgentMuxState, pane_id: string, text: string, submit?: boolean)

local M = {}

---@type table<AgentMuxBackendName, AgentMuxBackend>
local backends = {
  tmux = require("agentmux.backend.tmux"),
  herdr = require("agentmux.backend.herdr"),
}

---@return AgentMuxBackendName
function M.detect()
  if vim.env.HERDR_ENV == "1" or vim.env.HERDR_PANE_ID then
    return "herdr"
  end

  return "tmux"
end

---@param name "auto" | AgentMuxBackendName | nil
---@return AgentMuxBackend
function M.get(name)
  if not name or name == "auto" then
    name = M.detect()
  end

  return backends[name] or backends.tmux
end

return M
