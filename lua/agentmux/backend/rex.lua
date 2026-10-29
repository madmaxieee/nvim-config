local async_utils = require("utils.async")

---@class AgentMuxBackend
local M = {}

local function command(...)
  local bin = vim.env.REX_BIN_DIR and (vim.env.REX_BIN_DIR .. "/rex") or "rex"
  local cmd = { bin, "--autostart=false" }
  if vim.env.REX_SERVER then
    vim.list_extend(cmd, { "--server", vim.env.REX_SERVER })
  end
  vim.list_extend(cmd, { ... })
  return cmd
end

local function run(...)
  return vim.system(command(...), { text = true }):wait()
end

local function decode(res)
  if res.code ~= 0 then
    return nil
  end
  local ok, result = pcall(vim.json.decode, res.stdout or "")
  return ok and result or nil
end

local function notify_failure(action, res)
  local detail = vim.trim((res.stderr or "") .. "\n" .. (res.stdout or ""))
  vim.notify(
    "agentmux: failed to " .. action .. (detail ~= "" and ": " .. detail or ""),
    vim.log.levels.ERROR
  )
end

local function clear(state)
  state.backend = nil
  state.data = nil
end

local function resize_split(session, editor, agent)
  if not editor or not session or not agent then
    return
  end
  local res = run(
    "api",
    "call",
    "-s",
    session,
    "session.resize_pane",
    vim.json.encode({
      direction = "horizontal",
      before_block_id = editor,
      after_block_id = agent,
      ratio = 0.6,
    })
  )
  if res.code ~= 0 then
    notify_failure("resize Rex agent split", res)
  end
end

function M.get_pane_id(state)
  local data = state.data
  if not data or not data.pane_id then
    return nil
  end
  local res = run("block", "inspect", "-s", data.session_id, data.pane_id)
  if res.code ~= 0 then
    clear(state)
    return nil
  end
  return data.pane_id
end

function M.start(state, cfg)
  local editor = vim.env.REX_BLOCK
  local session = vim.env.REX_SESSION
  if not editor or not session then
    vim.notify("agentmux: start Neovim inside Rex", vim.log.levels.ERROR)
    return
  end

  local provider = cfg.providers[cfg.provider]
  local cmd = command(
    "split",
    "-s",
    session,
    "-b",
    editor,
    "--split",
    "right",
    "--ratio",
    "40",
    "--cwd",
    vim.fn.getcwd(),
    "--label",
    "agentmux:" .. editor,
    "--json",
    "--"
  )
  -- Run env in the new terminal, without changing the Rex CLI's own context.
  if next(provider.env or {}) then
    table.insert(cmd, "env")
    for key, value in pairs(provider.env) do
      table.insert(cmd, key .. "=" .. value)
    end
  end
  table.insert(cmd, provider.kind or cfg.provider)
  vim.list_extend(cmd, provider.args or {})

  local res = vim.system(cmd, { text = true }):wait()
  local result = decode(res)
  local pane_id = result and result.block_ids and result.block_ids[1]
  if not pane_id then
    notify_failure("create Rex agent split", res)
    return
  end
  -- seems more robust to wait a bit before resizing
  vim.uv.sleep(50)
  resize_split(session, editor, pane_id)

  state.backend = "rex"
  state.data = { pane_id = pane_id, session_id = session }
end

function M.restore_or_start(state, cfg, opts)
  local session = vim.env.REX_SESSION
  local editor = vim.env.REX_BLOCK
  if not session or not editor then
    M.start(state, cfg)
    return
  end
  state.backend = "rex"
  state.data = { pane_id = opts.pane_id, session_id = session }
  if not M.get_pane_id(state) then
    M.start(state, cfg)
    return
  end
  local res =
    run("block", "rename", "-s", session, opts.pane_id, "agentmux:" .. editor)
  if res.code ~= 0 then
    notify_failure("restore Rex editor pairing", res)
  end
end

function M.stop(state)
  local data = state.data
  if data and data.pane_id then
    local res = run("block", "close", "-s", data.session_id, data.pane_id)
    if res.code ~= 0 then
      notify_failure("close Rex agent", res)
      return
    end
  end
  clear(state)
end

function M.focus(state)
  local data = state.data
  if not data or not data.pane_id then
    return
  end
  local res = run("focus", "-s", data.session_id, data.pane_id)
  if res.code ~= 0 then
    notify_failure("focus Rex agent", res)
  end
end

function M.send_keys(state, keys)
  local data = state.data
  if not data or not data.pane_id then
    return
  end
  local cmd = command("send-key", "-s", data.session_id, "-b", data.pane_id)
  vim.list_extend(cmd, keys)
  local res = vim.system(cmd, { text = true }):wait()
  if res.code ~= 0 then
    notify_failure("send Rex keys", res)
  end
end

M.send_text = async_utils.wrapped(function(state, text, submit)
  local data = state.data
  if not data or not data.pane_id then
    return
  end
  -- Codex/OpenCode support bracketed paste: embedded newlines stay in the
  -- prompt instead of becoming Enter presses. Keep arbitrary text on stdin.
  local cmd = command("send", "-s", data.session_id, "-b", data.pane_id)
  local res = async_utils.system(cmd, {
    stdin = "\27[200~" .. text .. "\27[201~",
    text = true,
  })
  if res.code ~= 0 then
    async_utils.main_loop(notify_failure, "send Rex context", res)
    return
  end
  if submit then
    -- Give the TUI time to process the paste before submitting it.
    vim.async.sleep(100)
    if state.data == data then
      async_utils.main_loop(M.send_keys, state, { "enter" })
    end
  end
end)

return M
