local co2 = require("co2")

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

---@param ms number
---@param callback fun()
local function async_sleep(ms, callback)
  local timer = vim.uv.new_timer()
  if not timer then
    callback()
    return
  end
  timer:start(ms, 0, function()
    timer:close()
    callback()
  end)
end

---@param state AgentMuxState
---@param cfg AgentMuxConfig
function M.start(state, cfg)
  local data = backend_state(state)
  if data.starting then
    return
  end
  data.starting = true

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

  co2.run(function(ctx)
    local split_res = ctx.await(vim.system, split_cmd, {})
    if not data.starting then
      return
    end

    if split_res.code ~= 0 then
      data.starting = nil
      vim.schedule(function()
        vim.notify(
          "Failed to split pane for coding agent: " .. (split_res.stderr or ""),
          vim.log.levels.ERROR
        )
      end)
      return
    end

    local ok, split_data = pcall(vim.json.decode, split_res.stdout or "")
    if not ok then
      data.starting = nil
      vim.schedule(function()
        vim.notify(
          "Failed to parse pane split response: " .. (split_res.stdout or ""),
          vim.log.levels.ERROR
        )
      end)
      return
    end

    local pane_id = vim.tbl_get(split_data, "result", "pane", "pane_id")
    if not pane_id then
      data.starting = nil
      vim.schedule(function()
        vim.notify(
          "Failed to obtain pane id from split response",
          vim.log.levels.ERROR
        )
      end)
      return
    end

    -- resize the pane as soon as the split is created
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

    if provider.args and #provider.args > 0 then
      table.insert(start_cmd, "--")
      vim.list_extend(start_cmd, provider.args)
    end

    local res
    for _ = 1, 10 do
      res = ctx.await(vim.system, start_cmd, {})
      if not data.starting or res.code == 0 then
        break
      end
      ctx.await(async_sleep, 100)
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
      vim.schedule(function()
        vim.notify(
          "Failed to start coding agent in pane: " .. (res.stderr or ""),
          vim.log.levels.ERROR
        )
      end)
      vim.system({ "herdr", "pane", "close", pane_id })
      return
    end

    data.starting = nil
    data.pane_id = pane_id
    state.backend = "herdr"
  end)
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
