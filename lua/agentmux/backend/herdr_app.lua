-- Backend for the Herdr desktop app (`herdr-app`) and its terminal runtime,
-- herdr-core (`hc`).
--
-- Following `herdr-app --skill`, the app is only used for what the person
-- sees (splitting, sizing, focusing and pasting into panes), while hc drives
-- the terminal itself (liveness, labels, prompts, keys and cleanup).
--
-- The agent is tracked by its hc terminal address (`t7`), which stays valid
-- for the terminal's whole life, unlike its pane id, which changes when the
-- terminal is parked and shown again.

local async = vim.async

local async_utils = require("utils.async")

---@class AgentMuxBackend
local M = {}

local backend_name = "herdr-app"

-- Share of the editor pane's width given to the agent (like tmux's 35%).
local agent_weight = 0.35

---@class AgentMuxHerdrAppState
---@field terminal string? hc address of the agent's terminal, e.g. "t7"
---@field pane string? herdr-app pane showing the agent, when known
---@field starting boolean?

---@param state AgentMuxState
---@return AgentMuxHerdrAppState
local function backend_state(state)
  state.data = state.data or {}
  local data = state.data
  ---@cast data AgentMuxHerdrAppState
  return data
end

---@param state AgentMuxState
local function clear(state)
  state.backend = nil
  state.data = nil
end

---@param text string?
---@return any
local function decode(text)
  if not text or text == "" then
    return nil
  end
  local ok, result =
    pcall(vim.json.decode, text, { luanil = { object = true, array = true } })
  return ok and result or nil
end

---Extracts the error from a failed hc (`{error: {kind, message, hint}}` on
---stderr) or herdr-app (`{error: "..."}` on stdout) call.
---@param res vim.SystemCompleted
---@return string
local function error_message(res)
  local data = decode(res.stderr) or decode(res.stdout)
  local err = type(data) == "table" and data.error or nil
  if type(err) == "table" then
    return err.message or err.kind or vim.inspect(err)
  elseif type(err) == "string" then
    return err
  end
  return vim.trim((res.stderr or "") .. "\n" .. (res.stdout or ""))
end

---Safe to call from any context: tasks, fast callbacks and the main loop.
---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level)
  end)
end

---@param action string
---@param res vim.SystemCompleted
local function notify_failure(action, res)
  local detail = error_message(res)
  notify(
    "agentmux: failed to " .. action .. (detail ~= "" and ": " .. detail or ""),
    vim.log.levels.ERROR
  )
end

---@param command string
---@param args? table
---@return string[]
local function app_cmd(command, args)
  local cmd = { "herdr-app", "do", command }
  if args then
    table.insert(cmd, vim.json.encode(args))
  end
  return cmd
end

---Runs a herdr-app command against the open window.
---@async
---@param command string
---@param args? table
---@return vim.SystemCompleted res
---@return table? result the decoded reply, when the command succeeded
local function app_do(command, args)
  local res = async_utils.system(app_cmd(command, args), { text = true })
  return res, res.code == 0 and decode(res.stdout) or nil
end

---@param subcommand string
---@param ... string positional arguments, passed after `--`
---@return string[]
local function hc_cmd(subcommand, ...)
  local cmd = { "hc", subcommand, "--json", "--" }
  vim.list_extend(cmd, { ... })
  return cmd
end

---@async
---@param terminal string
---@return vim.SystemCompleted res
---@return table? info the terminal's facts, when it exists
local function hc_get(terminal)
  local res = async_utils.system(hc_cmd("get", terminal), { text = true })
  return res, res.code == 0 and decode(res.stdout) or nil
end

---Ends the terminal's program (closing its pane) and forgets the finished
---terminal. Detached so that it also completes when Neovim is exiting.
---@param terminal string
local function kill_detached(terminal)
  -- stylua: ignore
  vim.system({
    "sh", "-c",
    [[hc kill -- "$1" >/dev/null 2>&1; hc rm -- "$1" >/dev/null 2>&1]],
    "agentmux", terminal,
  }, { detach = true })
end

---Finds the pane showing this Neovim's own terminal, so the agent is split off
---next to it rather than next to whichever pane happens to be focused.
---@async
---@param me string? this Neovim's hc terminal address ($HC_TERMINAL_ID)
---@return string? pane
---@return string? err
local function find_editor_pane(me)
  if not me then
    return nil, "$HC_TERMINAL_ID is not set, start Neovim inside herdr-app"
  end

  local res = async_utils.system({ "herdr-app", "ls" }, { text = true })
  local data = res.code == 0 and decode(res.stdout) or nil
  if not data then
    return nil, "herdr-app window is not reachable: " .. error_message(res)
  end

  local function search(terminals)
    for _, term in ipairs(terminals or {}) do
      if term.terminal == me and term.pane then
        return term.pane
      end
      local found = search(term.sub_agents)
      if found then
        return found
      end
    end
  end

  for _, space in ipairs(data.spaces or {}) do
    for _, tab in ipairs(space.tabs or {}) do
      local pane = search(tab.terminals)
      if pane then
        return pane
      end
    end
  end
  return nil, ("terminal %s is not shown in a herdr-app pane"):format(me)
end

---Builds the argv run in the new pane. `pane.split` has no folder or
---environment arguments, so a tiny sh wrapper sets both before exec'ing the
---agent; the agent itself still owns the terminal and reports its status.
---Must run on the main loop (uses vim.fn).
---@param cfg AgentMuxConfig
---@param cwd string
---@param extra_args? string[]
---@return string[]
local function build_argv(cfg, cwd, extra_args)
  local provider = cfg.providers[cfg.provider]
  local kind = provider.kind or cfg.provider
  -- Resolve with Neovim's PATH: the core's environment may differ.
  local exe = vim.fn.exepath(kind)

  -- stylua: ignore
  local argv = {
    "sh", "-c", [[cd "$1" || exit; shift; exec "$@"]],
    "agentmux", cwd,
  }

  local env = {}
  for key, value in pairs(provider.env or {}) do
    table.insert(env, ("%s=%s"):format(key, value))
  end
  if #env > 0 then
    table.sort(env)
    table.insert(argv, "env")
    vim.list_extend(argv, env)
  end

  table.insert(argv, exe ~= "" and exe or kind)
  vim.list_extend(argv, provider.herdr_app_args or {})
  vim.list_extend(argv, provider.args or {})
  vim.list_extend(argv, extra_args or {})
  return argv
end

---@class AgentMuxHerdrAppStartOpts
---@field cwd? string agent working directory (defaults to vim.fn.getcwd())
---@field extra_args? string[] appended after provider.args

---@async
---@param state AgentMuxState
---@param cfg AgentMuxConfig
---@param opts? AgentMuxHerdrAppStartOpts
local function start_agent(state, cfg, opts)
  opts = opts or {}
  local data = backend_state(state)
  if data.starting then
    return
  end
  data.starting = true

  -- read everything that needs the main loop before the first await
  local argv = build_argv(cfg, opts.cwd or vim.fn.getcwd(), opts.extra_args)
  local me = vim.env.HC_TERMINAL_ID
  local labels = {
    "agentmux.provider=" .. cfg.provider,
    "agentmux.editor=" .. (me or ""),
  }

  local editor_pane, err = find_editor_pane(me)
  if not data.starting then
    return
  end
  if not editor_pane then
    data.starting = nil
    notify("agentmux: " .. err, vim.log.levels.ERROR)
    return
  end

  local res, result = app_do("pane.split", {
    direction = "right",
    pane = editor_pane,
    argv = argv,
  })
  local terminal = result and result.terminal

  -- the start action was canceled by M.stop() while splitting
  if not data.starting then
    if terminal then
      kill_detached(terminal)
    end
    return
  end

  data.starting = nil
  if type(terminal) ~= "string" then
    notify_failure("split pane for coding agent", res)
    return
  end

  data.terminal = terminal
  data.pane = result.pane
  state.backend = backend_name

  -- Labels make agentmux terminals discoverable with `hc ls --label`.
  async_utils.system(hc_cmd("label", terminal, unpack(labels)), { text = true })

  -- Size the split right away. Splitting halves the editor pane, so these
  -- weights are relative to its original size.
  if data.pane then
    app_do("layout.resize", { id = editor_pane, weight = 1 - agent_weight })
    app_do("layout.resize", { id = data.pane, weight = agent_weight })
  end

  -- like `herdr pane split --focus`
  local focus_res = app_do("pane.focus", { terminal = terminal })
  if focus_res.code ~= 0 then
    notify_failure("focus agent pane", focus_res)
  end
end

-- The task runs synchronously up to its first await, so the `starting` guard
-- still wins races between two calls.
M.start = async_utils.wrapped(start_agent)

function M.get_pane_id(state)
  local data = backend_state(state)
  local terminal = data.terminal
  if terminal then
    local res = vim.system(hc_cmd("get", terminal), { text = true }):wait()
    local info = res.code == 0 and decode(res.stdout) or nil
    if not info or info.state ~= "live" then
      if info then
        -- the agent exited on its own: forget its finished terminal
        vim.system(hc_cmd("rm", terminal))
      end
      data.terminal = nil
      clear(state)
    end
  end
  return data.terminal
end

---@async
---@param state AgentMuxState
---@param cfg AgentMuxConfig
---@param restore_opts AgentMuxRestoreOpts
M.restore_or_start = async_utils.wrapped(function(state, cfg, restore_opts)
  local _, info = hc_get(restore_opts.pane_id)

  if not info or info.state ~= "live" then
    -- Entered inline rather than through M.start, to stay in this task.
    -- start_agent reads vim.fn before its first await, so it has to begin on
    -- the main loop.
    async_utils.main_loop(start_agent, state, cfg)
    return
  end

  local data = backend_state(state)
  data.terminal = restore_opts.pane_id
  state.backend = backend_name
  notify("agentmux: restored link to agent terminal")
end)

---Ends the agent and starts it again in the same folder, continuing its most
---recent session. hc does not expose an agent's session id, so this relies on
---the provider's `resume_last_args`.
---@async
---@param state AgentMuxState
---@param cfg AgentMuxConfig
M.restart = async_utils.wrapped(function(state, cfg)
  local data = backend_state(state)
  local terminal = data.terminal
  if not terminal or data.starting then
    return
  end

  local provider = cfg.providers[cfg.provider]
  if not provider.resume_last_args then
    notify(
      ("agentmux: provider %s does not define resume_last_args"):format(
        cfg.provider
      ),
      vim.log.levels.ERROR
    )
    return
  end

  local res, info = hc_get(terminal)
  if not info then
    notify_failure("query agent terminal", res)
    return
  end

  -- bail out if the agent changed while we were querying it
  if data ~= state.data or data.terminal ~= terminal then
    return
  end

  clear(state)
  -- wait for the agent to exit so its session is saved before resuming it
  async_utils.system(hc_cmd("kill", terminal), { text = true })
  async_utils.system(hc_cmd("rm", terminal), { text = true })

  local cwd = vim.tbl_get(info, "foreground", "cwd")
  -- start_agent reads vim.fn before its first await, so it has to begin on
  -- the main loop.
  async_utils.main_loop(start_agent, state, cfg, {
    cwd = type(cwd) == "string" and cwd or nil,
    extra_args = provider.resume_last_args,
  })
end)

function M.stop(state)
  local data = backend_state(state)
  if data.terminal then
    kill_detached(data.terminal)
  end
  data.starting = nil
  clear(state)
end

function M.focus(state)
  local terminal = backend_state(state).terminal
  if not terminal then
    return
  end

  local args = { terminal = terminal }
  vim.system(app_cmd("pane.focus", args), { text = true }, function(res)
    if res.code == 0 then
      return
    end
    -- e.g. the terminal was parked: agent.focus still shows it
    vim.system(app_cmd("agent.focus", args), { text = true }, function(res2)
      if res2.code ~= 0 then
        notify_failure("focus agent", res)
      end
    end)
  end)
end

function M.send_keys(state, keys)
  local terminal = backend_state(state).terminal
  if not terminal then
    return
  end

  local cmd = hc_cmd("keys", terminal)
  vim.list_extend(cmd, keys)
  vim.system(cmd, { text = true }, function(res)
    if res.code ~= 0 then
      notify_failure("send keys to agent", res)
    end
  end)
end

---@return string[]? copy
---@return string[]? paste
local function clipboard_tools()
  if vim.fn.has("mac") == 1 then
    return { "pbcopy" }, { "pbpaste" }
  end
  if
    vim.env.WAYLAND_DISPLAY
    and vim.fn.executable("wl-copy") == 1
    and vim.fn.executable("wl-paste") == 1
  then
    return { "wl-copy" }, { "wl-paste", "--no-newline" }
  end
  if vim.fn.executable("xclip") == 1 then
    return { "xclip", "-selection", "clipboard" }, {
      "xclip",
      "-selection",
      "clipboard",
      "-o",
    }
  end
end

---Writes to the system clipboard. Clipboard tools may fork a process that
---keeps serving the selection, so their output is not piped (and not
---waited on).
---@async
---@param copy string[]
---@param text string
---@return vim.SystemCompleted
local function set_clipboard(copy, text)
  return async_utils.system(
    copy,
    { stdin = text, stdout = false, stderr = false }
  )
end

---Puts text into the agent's prompt without submitting it.
---
---hc can only paste text together with Enter (`hc send`), and `hc keys` only
---knows named keys, so this goes through the window instead: it pastes the
---system clipboard into the agent's pane with `terminal.paste` (honoring the
---program's bracketed paste mode), then restores the previous clipboard text.
---This leaves the agent pane focused.
---@async
---@param terminal string
---@param text string
---@param copy string[]?
---@param paste string[]?
local function paste_text(terminal, text, copy, paste)
  if not copy or not paste then
    notify(
      "agentmux: no clipboard tool found to paste into the agent",
      vim.log.levels.ERROR
    )
    return
  end

  local saved = async_utils.system(paste, { text = true })

  local copy_res = set_clipboard(copy, text)
  if copy_res.code ~= 0 then
    notify("agentmux: failed to copy text to clipboard", vim.log.levels.ERROR)
    return
  end

  -- terminal.paste pastes into the terminal holding keyboard focus
  local focus_res = app_do("pane.focus", { terminal = terminal })
  if focus_res.code ~= 0 then
    notify_failure("focus agent pane", focus_res)
  else
    local paste_res = app_do("terminal.paste")
    if paste_res.code ~= 0 then
      notify_failure("paste into agent", paste_res)
    end
  end

  -- Only text can be restored; an empty read means there was none (or it was
  -- something else, such as an image, which pbpaste can't read).
  if saved.code == 0 and saved.stdout and saved.stdout ~= "" then
    -- give the window time to read the clipboard before restoring it
    async.sleep(200)
    set_clipboard(copy, saved.stdout)
  end
end

M.send_text = async_utils.wrapped(function(state, text, submit)
  local terminal = backend_state(state).terminal
  if not terminal then
    return
  end

  if submit then
    -- pastes, then presses the program's submit key once the paste landed;
    -- refuses (instead of answering it) when the agent is blocked on a dialog
    local res =
      async_utils.system(hc_cmd("send", terminal, text), { text = true })
    if res.code ~= 0 then
      notify_failure("send prompt to agent", res)
    end
    return
  end

  -- resolve the tools before the first await, while still on the main loop
  local copy, paste = clipboard_tools()
  paste_text(terminal, text, copy, paste)
end)

return M
