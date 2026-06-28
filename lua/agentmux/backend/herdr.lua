---@class AgentMuxHerdrBackend : AgentMuxBackend
---@field resolve_pane_id fun(target: string): string?

---@type AgentMuxHerdrBackend
local M = {}

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
  if state.pane_id then
    local res = vim.system({ "herdr", "agent", "get", state.pane_id }):wait()
    if res.code ~= 0 then
      state.pane_id = nil
      state.backend = nil
    end
  end
  return state.pane_id
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

  state.pane_id = target
  state.backend = "herdr"
end

function M.stop(state, _, pane_id)
  local resolved_pane_id = M.resolve_pane_id(pane_id)
  if resolved_pane_id then
    vim.system({ "herdr", "pane", "close", resolved_pane_id })
  end
  state.pane_id = nil
  state.backend = nil
end

function M.focus(_, pane_id)
  vim.system({ "herdr", "agent", "focus", pane_id })
end

function M.send_keys(_, pane_id, keys)
  if #keys == 1 and keys[1] == "Enter" then
    vim.system({ "herdr", "agent", "send", pane_id, "\n" })
    return
  end

  local resolved_pane_id = M.resolve_pane_id(pane_id)
  if not resolved_pane_id then
    return
  end

  local cmd = { "herdr", "pane", "send-keys", resolved_pane_id }
  vim.list_extend(cmd, keys)
  vim.system(cmd)
end

function M.send_text(_, pane_id, text, submit)
  vim.system({
    "herdr",
    "agent",
    "send",
    pane_id,
    submit and text .. "\n" or text,
  })
end

return M
