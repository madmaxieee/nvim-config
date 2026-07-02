---@type AgentMuxBackend
local M = {}

local tmux_return_focus_key = "C-."

---@class AgentMuxTmuxState
---@field pane_id string?

---@param state AgentMuxState
---@return AgentMuxTmuxState
local function backend_state(state)
  state.data = state.data or {}
  local data = state.data
  ---@cast data AgentMuxTmuxState
  return data
end

function M.get_pane_id(state)
  local data = backend_state(state)
  if data.pane_id then
    local res = vim.system({ "tmux", "list-panes", "-t", data.pane_id }):wait()
    if res.code ~= 0 then
      data.pane_id = nil
      state.backend = nil
      state.data = nil
    end
  end
  return data.pane_id
end

function M.start(state, cfg)
  local provider = cfg.providers[cfg.provider]

  -- stylua: ignore
  local create_pane_cmd = {
    -- create a new pane
    "tmux", "split-window",
    -- print the pane id to stdout so we can capture it
    "-P", "-F", "#{pane_id}",
    -- split "horizontally", to the right
    "-h",
    "-p", "35",
  }

  vim.list_extend(create_pane_cmd, provider.command)

  local res = vim.system(create_pane_cmd, { env = provider.env }):wait()
  if res.code ~= 0 then
    vim.notify(
      "Failed to create coding agent pane: " .. res.stderr,
      vim.log.levels.ERROR
    )
    return
  end

  local data = backend_state(state)
  data.pane_id = vim.trim(res.stdout)
  state.backend = "tmux"

  -- stylua: ignore
  vim.system({
    "tmux", "set-option", "-t", data.pane_id,
    "-p", "@agent-mux-pane", vim.env.TMUX_PANE,
  })
  -- stylua: ignore
  vim.system({
    "tmux", "bind-key", "-n", tmux_return_focus_key,
    "if-shell", "-F", "#{?#{@agent-mux-pane},1,0}",
    [[ run-shell 'tmux select-pane -t "#{@agent-mux-pane}"' ]],
    ("send-keys %s"):format(tmux_return_focus_key),
  })
end

function M.stop(state, cfg)
  local data = backend_state(state)
  local pane_id = data.pane_id
  if not pane_id then
    return
  end

  local provider = cfg.providers[cfg.provider]
  if provider.stop_agent then
    provider.stop_agent(pane_id)
  else
    vim.system({ "tmux", "kill-pane", "-t", pane_id })
  end

  -- unbind the keybinding
  vim.system({ "tmux", "unbind-key", "-n", tmux_return_focus_key })
  state.backend = nil
  state.data = nil
end

function M.focus(state)
  local pane_id = backend_state(state).pane_id
  if not pane_id then
    return
  end

  vim.system({ "tmux", "select-pane", "-t", pane_id })
end

function M.send_keys(state, keys)
  local pane_id = backend_state(state).pane_id
  if not pane_id then
    return
  end

  local cmd = { "tmux", "send-keys", "-t", pane_id }
  vim.list_extend(cmd, keys)
  vim.system(cmd)
end

return M
