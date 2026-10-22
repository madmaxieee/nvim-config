local async = vim.async

local async_utils = require("utils.async")

---@class AgentMuxBackend
local M = {}

---@class AgentMuxHerdrState
---@field pane_id string?
---@field starting boolean?

---@param state AgentMuxState
---@return AgentMuxHerdrState
local function backend_state(state)
  state.data = state.data or {}
  local data = state.data
  ---@cast data AgentMuxHerdrState
  return data
end

local function target_name(provider)
  local cwd_hash = vim.fn.sha256(vim.fn.getcwd()):sub(1, 6)
  return ("amux-%s-%s-%x"):format(provider, cwd_hash, vim.uv.os_getpid())
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

---@class AgentMuxHerdrStartOpts
---@field name? string agent name (defaults to target_name(provider))
---@field cwd? string pane working directory (defaults to vim.fn.getcwd())
---@field extra_args? string[] appended after provider.args

---@async
---@param state AgentMuxState
---@param cfg AgentMuxConfig
---@param opts? AgentMuxHerdrStartOpts
local function start_agent(state, cfg, opts)
  opts = opts or {}
  local data = backend_state(state)
  if data.starting then
    return
  end
  data.starting = true

  local provider = cfg.providers[cfg.provider]
  local target = opts.name or target_name(cfg.provider)
  local kind = provider.kind or cfg.provider

  -- stylua: ignore
  local split_cmd = {
    "herdr", "pane", "split",
    "--direction", "right",
    "--cwd", opts.cwd or vim.fn.getcwd(),
    "--focus",
  }

  for key, value in pairs(provider.env or {}) do
    vim.list_extend(split_cmd, { "--env", ("%s=%s"):format(key, value) })
  end

  local split_res = async_utils.system(split_cmd, {})
  if not data.starting then
    return
  end

  if split_res.code ~= 0 then
    data.starting = nil
    async_utils.notify(
      "Failed to split pane for coding agent: " .. (split_res.stderr or ""),
      vim.log.levels.ERROR
    )
    return
  end

  local ok, split_data = pcall(vim.json.decode, split_res.stdout or "")
  if not ok then
    data.starting = nil
    async_utils.notify(
      "Failed to parse pane split response: " .. (split_res.stdout or ""),
      vim.log.levels.ERROR
    )
    return
  end

  local pane_id = vim.tbl_get(split_data, "result", "pane", "pane_id")
  if not pane_id then
    data.starting = nil
    async_utils.notify(
      "Failed to obtain pane id from split response",
      vim.log.levels.ERROR
    )
    return
  end

  -- resize the pane as soon as the split is created
  -- stylua: ignore
  vim.system({
    "herdr", "pane", "resize",
    "--direction", "right",
    "--amount", "0.1",
    "--pane", pane_id,
  }, { detach = true })

  -- stylua: ignore
  local start_cmd = {
    "herdr", "agent", "start", target,
    "--kind", kind,
    "--pane", pane_id,
  }

  local agent_args = vim.list_extend(
    vim.list_extend({}, provider.args or {}),
    opts.extra_args or {}
  )
  if #agent_args > 0 then
    table.insert(start_cmd, "--")
    vim.list_extend(start_cmd, agent_args)
  end

  local res
  for _ = 1, 10 do
    res = async_utils.system(start_cmd, {})
    if not data.starting or res.code == 0 then
      break
    end
    async.sleep(100)
    if not data.starting then
      break
    end
  end

  -- return early if the start action is canceled by M.stop()
  if not data.starting then
    vim.system({ "herdr", "pane", "close", pane_id })
    return
  end

  if res.code ~= 0 then
    data.starting = nil
    async_utils.notify(
      "Failed to start coding agent in pane: " .. (res.stderr or ""),
      vim.log.levels.ERROR
    )
    vim.system({ "herdr", "pane", "close", pane_id })
    return
  end

  data.starting = nil
  data.pane_id = pane_id
  state.backend = "herdr"
end

-- The task runs synchronously up to its first await, so the `starting` guard
-- still wins races between two calls.
M.start = async_utils.wrapped(start_agent)

---@async
---@param state AgentMuxState
---@param cfg AgentMuxConfig
---@param restore_opts AgentMuxRestoreOpts
M.restore_or_start = async_utils.wrapped(function(state, cfg, restore_opts)
  local res = async_utils.system(
    { "herdr", "agent", "get", restore_opts.pane_id },
    {}
  )

  if res.code ~= 0 then
    -- Entered inline rather than through M.start, to stay in this task instead
    -- of spawning a child one. start_agent reads vim.fn before its first
    -- await, so it has to begin on the main loop.
    async_utils.main_loop(start_agent, state, cfg)
    return
  end

  local data = backend_state(state)
  data.pane_id = restore_opts.pane_id
  state.backend = "herdr"
  async_utils.notify("agentmux: restored link to agent pane")
end)

---Closes the agent pane and reopens it with the same agent name, resuming the
---same agent session.
---@async
---@param state AgentMuxState
---@param cfg AgentMuxConfig
M.restart = async_utils.wrapped(function(state, cfg)
  local data = backend_state(state)
  local pane_id = data.pane_id
  if not pane_id or data.starting then
    return
  end

  local provider = cfg.providers[cfg.provider]
  if not provider.resume_args then
    async_utils.notify(
      ("agentmux: provider %s does not define resume_args"):format(cfg.provider),
      vim.log.levels.ERROR
    )
    return
  end

  local get_res = async_utils.system({ "herdr", "agent", "get", pane_id }, {})
  local ok, get_data = pcall(vim.json.decode, get_res.stdout or "")
  if get_res.code ~= 0 or not ok then
    async_utils.notify(
      "agentmux: failed to query agent: " .. (get_res.stderr or ""),
      vim.log.levels.ERROR
    )
    return
  end

  local agent = vim.tbl_get(get_data, "result", "agent") or {}
  local session_id = vim.tbl_get(agent, "agent_session", "value")
  if type(session_id) ~= "string" or session_id == "" then
    async_utils.notify(
      "agentmux: agent has no session id, not restarting",
      vim.log.levels.ERROR
    )
    return
  end

  -- bail out if the pane changed while we were querying it
  if data ~= state.data or data.pane_id ~= pane_id then
    return
  end

  -- close the pane and wait so the agent name is released before reuse
  state.backend = nil
  state.data = nil
  async_utils.system({ "herdr", "pane", "close", pane_id }, {})

  -- start_agent reads vim.fn before its first await, so it has to begin on
  -- the main loop.
  async_utils.main_loop(start_agent, state, cfg, {
    name = type(agent.name) == "string" and agent.name or nil,
    cwd = type(agent.cwd) == "string" and agent.cwd or nil,
    extra_args = provider.resume_args(session_id),
  })
end)

function M.stop(state)
  local data = backend_state(state)
  if data.pane_id then
    vim.system({ "herdr", "pane", "close", data.pane_id })
  end
  if data.starting then
    data.starting = nil
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
