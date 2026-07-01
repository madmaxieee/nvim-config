---@class AgentMuxHerdrBackend : AgentMuxBackend
local M = {}

---@class AgentMuxHerdrState
---@field target string?
---@field pane_id string?

---@param state AgentMuxState
---@return AgentMuxHerdrState
local function backend_state(state)
  state.data = state.data or {}
  local data = state.data
  ---@cast data AgentMuxHerdrState
  return data
end

local function target_name(provider)
  local cwd_hash = vim.fn.sha256(vim.fn.getcwd()):sub(1, 8)
  return ("agentmux-%s-%s-%s"):format(provider, cwd_hash, vim.uv.os_getpid())
end

function M.resolve_pane_id(target)
  local res = vim.system({ "herdr", "agent", "get", target }):wait()
  if res.code ~= 0 then
    return nil
  end

  local ok, data = pcall(vim.json.decode, res.stdout)
  if not ok then
    return nil
  end

  return vim.tbl_get(data, "result", "agent", "pane_id")
end

function M.get_pane_id(state)
  local data = backend_state(state)
  if data.target then
    data.pane_id = M.resolve_pane_id(data.target)
    if not data.pane_id then
      data.target = nil
      state.backend = nil
      state.data = nil
    end
  end
  return data.pane_id
end

function M.start(state, cfg)
  local provider = cfg.providers[cfg.provider]
  local target = target_name(cfg.provider)

  -- stylua: ignore
  local cmd = {
    "herdr", "agent", "start", target,
    "--cwd", vim.fn.getcwd(),
    "--split", "right",
  }

  for key, value in pairs(provider.env or {}) do
    vim.list_extend(cmd, { "--env", ("%s=%s"):format(key, value) })
  end

  table.insert(cmd, "--focus")
  table.insert(cmd, "--")
  vim.list_extend(cmd, vim.split(provider.command, " ", { trimempty = true }))

  local res = vim.system(cmd):wait()
  if res.code ~= 0 then
    vim.notify(
      "Failed to create coding agent pane: " .. res.stderr,
      vim.log.levels.ERROR
    )
    return
  end

  local data = backend_state(state)
  data.target = target
  data.pane_id = M.resolve_pane_id(target)
  state.backend = "herdr"

  if data.pane_id then
    vim.system({
      "herdr",
      "pane",
      "resize",
      "--direction",
      "right",
      "--amount",
      "0.1",
      "--pane",
      data.pane_id,
    })
  end
end

function M.stop(state)
  local data = backend_state(state)
  if data.pane_id then
    vim.system({ "herdr", "pane", "close", data.pane_id })
  end
  state.backend = nil
  state.data = nil
end

function M.focus(state)
  local target = backend_state(state).target
  if not target then
    return
  end

  vim.system({ "herdr", "agent", "focus", target })
end

function M.send_keys(state, keys)
  local data = backend_state(state)

  if #keys == 1 and keys[1] == "Enter" then
    if data.target then
      vim.system({ "herdr", "agent", "send", data.target, "\n" })
    end
    return
  end

  if not data.pane_id then
    return
  end

  local cmd = { "herdr", "pane", "send-keys", data.pane_id }
  vim.list_extend(cmd, keys)
  vim.system(cmd)
end

function M.send_text(state, text, submit)
  local target = backend_state(state).target
  if not target then
    return
  end

  vim.system({
    "herdr",
    "agent",
    "send",
    target,
    submit and text .. "\r" or text,
  })
end

return M
