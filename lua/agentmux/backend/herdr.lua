---@class AgentMuxBackend
local M = {}

---@class AgentMuxHerdrState
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

function M.get_pane_id(state)
  local data = backend_state(state)
  if data.pane_id then
    local res = vim.system({ "herdr", "agent", "get", data.pane_id }):wait()
    if res.code ~= 0 then
      data.pane_id = nil
      state.backend = nil
      state.data = nil
    end
  end
  return data.pane_id
end

---@param state AgentMuxState
---@param cfg AgentMuxConfig
function M.start(state, cfg)
  local provider = cfg.providers[cfg.provider]
  local target = target_name(cfg.provider)
  local kind = provider.kind or cfg.provider

  -- stylua: ignore
  local split_cmd = {
    "herdr", "pane", "split",
    "--direction", "right",
    "--cwd", vim.fn.getcwd(),
    "--focus",
  }

  for key, value in pairs(provider.env or {}) do
    vim.list_extend(split_cmd, { "--env", ("%s=%s"):format(key, value) })
  end

  local split_res = vim.system(split_cmd):wait()
  if split_res.code ~= 0 then
    vim.notify(
      "Failed to split pane for coding agent: " .. split_res.stderr,
      vim.log.levels.ERROR
    )
    return
  end

  local ok, split_data = pcall(vim.json.decode, split_res.stdout)
  if not ok then
    vim.notify(
      "Failed to parse pane split response: " .. split_res.stdout,
      vim.log.levels.ERROR
    )
    return
  end

  local pane_id = vim.tbl_get(split_data, "result", "pane", "pane_id")
  if not pane_id then
    vim.notify(
      "Failed to obtain pane id from split response",
      vim.log.levels.ERROR
    )
    return
  end

  -- stylua: ignore
  vim.system({
    "herdr", "pane", "resize",
    "--direction", "right",
    "--amount", "0.1",
    "--pane", pane_id,
  })

  -- stylua: ignore
  local start_cmd = {
    "herdr", "agent", "start", target,
    "--kind", kind,
    "--pane", pane_id,
  }

  if #provider.command > 1 then
    table.insert(start_cmd, "--")
    for i = 2, #provider.command do
      table.insert(start_cmd, provider.command[i])
    end
  end

  local res
  for _ = 1, 30 do
    res = vim.system(start_cmd):wait()
    if res.code == 0 then
      break
    end
    vim.uv.sleep(100)
  end

  if res.code ~= 0 then
    vim.notify(
      "Failed to start coding agent in pane: " .. res.stderr,
      vim.log.levels.ERROR
    )
    vim.system({ "herdr", "pane", "close", pane_id })
    return
  end

  local data = backend_state(state)
  data.pane_id = pane_id
  state.backend = "herdr"
end

function M.restore_or_start(state, cfg, restore_opts)
  local res =
    vim.system({ "herdr", "agent", "get", restore_opts.pane_id }):wait()
  if res.code == 0 then
    local data = backend_state(state)
    data.pane_id = restore_opts.pane_id
    state.backend = "herdr"
    vim.notify("agentmux: restored link to agent pane")
  else
    M.start(state, cfg)
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
  local pane_id = backend_state(state).pane_id
  if not pane_id then
    return
  end

  vim.system({ "herdr", "agent", "focus", pane_id })
end

function M.send_keys(state, keys)
  local pane_id = backend_state(state).pane_id
  if not pane_id then
    return
  end

  local cmd = { "herdr", "agent", "send-keys", pane_id }
  vim.list_extend(cmd, keys)
  vim.system(cmd)
end

function M.send_text(state, text, submit)
  local pane_id = backend_state(state).pane_id
  if not pane_id then
    return
  end

  if submit then
    vim.system({ "herdr", "agent", "prompt", pane_id, text })
  else
    vim.system({ "herdr", "pane", "send-text", pane_id, text })
  end
end

return M
