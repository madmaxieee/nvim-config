---@alias AgentMuxBackendName "tmux" | "herdr" | "herdr-app" | "rex"

---@class AgentMuxState
---@field backend AgentMuxBackendName?
---@field data table?

---@class AgentMuxBackend
---@field get_pane_id fun(state: AgentMuxState): string?
---@field start fun(state: AgentMuxState, cfg: AgentMuxConfig)
---@field restore_or_start fun(state: AgentMuxState, cfg: AgentMuxConfig, restore_opts: AgentMuxRestoreOpts)
---@field stop fun(state: AgentMuxState, cfg: AgentMuxConfig)
---@field restart? fun(state: AgentMuxState, cfg: AgentMuxConfig)
---@field focus fun(state: AgentMuxState)
---@field send_keys fun(state: AgentMuxState, keys: string[])
---@field send_text? fun(state: AgentMuxState, text: string, submit?: boolean)

local M = {}

---@type table<AgentMuxBackendName, AgentMuxBackend>
local backends = {
  tmux = require("agentmux.backend.tmux"),
  herdr = require("agentmux.backend.herdr"),
  ["herdr-app"] = require("agentmux.backend.herdr_app"),
  rex = require("agentmux.backend.rex"),
}

---@type AgentMuxBackendName?
local detected

---@return AgentMuxBackendName
function M.detect()
  if detected then
    return detected
  end

  if require("flags").is_herdr then
    detected = "herdr"
  elseif vim.env.REX_BLOCK and vim.env.REX_SESSION then
    detected = "rex"
  elseif vim.env.HC_TERMINAL_ID then
    detected = "herdr-app"
  else
    detected = "tmux"
  end

  return detected
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
