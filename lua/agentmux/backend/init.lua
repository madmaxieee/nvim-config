---@alias AgentMuxBackendName "tmux" | "herdr"

---@class AgentMuxState
---@field backend AgentMuxBackendName?
---@field data table?

---@class AgentMuxBackend
---@field get_pane_id fun(state: AgentMuxState): string?
---@field start fun(state: AgentMuxState, cfg: AgentMuxConfig)
---@field restore_or_start fun(state: AgentMuxState, cfg: AgentMuxConfig, restore_opts: AgentMuxRestoreOpts)
---@field stop fun(state: AgentMuxState, cfg: AgentMuxConfig)
---@field focus fun(state: AgentMuxState)
---@field send_keys fun(state: AgentMuxState, keys: string[])
---@field send_text? fun(state: AgentMuxState, text: string, submit?: boolean)

local M = {}

---@type table<AgentMuxBackendName, AgentMuxBackend>
local backends = {
  tmux = require("agentmux.backend.tmux"),
  herdr = require("agentmux.backend.herdr"),
}

---@return AgentMuxBackendName
function M.detect()
  if require("flags").is_herdr then
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
