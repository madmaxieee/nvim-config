---@class AgentMuxOptions
---@field provider string
---@field backend? "auto" | AgentMuxBackendName pane backend (default: "auto")

---@class AgentMuxProvider
---@field kind? string agent kind and canonical executable (defaults to provider name)
---@field args? string[] additional command line arguments passed to the agent executable
---@field env? table<string, string>
---@field tmux_stop_agent? fun(pane_id: string) backend stop hook
---@field format_keys? fun(text: string): string[] construct tmux send-keys arguments from text to send
---@field resume_args? fun(session_id: string): string[] agent arguments that resume the given session

---@class AgentMuxConfig : AgentMuxOptions
---@field providers? table<string, AgentMuxProvider>
---@field prompts? string[]

---@class AgentMuxRestoreOpts
---@field backend "auto" | AgentMuxBackendName
---@field provider string
---@field pane_id string

---@type AgentMuxConfig
local cfg = {
  provider = "codex",
  backend = "auto",
  providers = {
    opencode = {
      resume_args = function(session_id)
        return { "--session", session_id }
      end,
      tmux_stop_agent = function(pane_id)
        vim.system({ "tmux", "send-keys", "-t", pane_id, "C-c", "C-d" })
      end,
    },
    codex = {
      resume_args = function(session_id)
        return { "resume", session_id }
      end,
      tmux_stop_agent = function(pane_id)
        vim.system({ "tmux", "send-keys", "-t", pane_id, "C-d" })
      end,
    },
  },
  prompts = {
    "@diag ---\nfix these",
    "@marx",
  },
}

---@type AgentMuxState
local state = {}

local M = {}

local backend_registry = require("agentmux.backend")

---@param opts AgentMuxConfig
function M.setup(opts)
  cfg = vim.tbl_deep_extend("force", cfg, opts or {})
end

local function get_backend(opts)
  local name = opts and opts.backend or state.backend or cfg.backend or "auto"
  return backend_registry.get(name)
end

function M.is_active()
  return M.get_pane_id() ~= nil
end

function M.get_pane_id()
  return get_backend().get_pane_id(state)
end

---@param opts AgentMuxOptions?
function M.start(opts)
  if M.get_pane_id() then
    return
  end

  opts = vim.tbl_deep_extend("force", cfg, opts or {})
  get_backend(opts).start(state, opts)
end

---@param opts AgentMuxOptions?
function M.new(opts)
  if M.is_active() then
    M.send("/new", { submit = true })
  else
    M.start(opts)
  end
end

---@param opts AgentMuxRestoreOpts
function M.restore(opts)
  get_backend({ backend = opts.backend }).restore_or_start(state, cfg, opts)
end

function M.stop()
  if not M.get_pane_id() then
    return
  end

  get_backend().stop(state, cfg)
end

---Stops the agent and reopens it with the same name, resuming the same session.
function M.restart()
  if not M.get_pane_id() then
    vim.notify("Agent pane is not active", vim.log.levels.WARN)
    return
  end

  local backend = get_backend()
  if not backend.restart then
    vim.notify(
      "agentmux: restart is not supported by this backend",
      vim.log.levels.WARN
    )
    return
  end
  backend.restart(state, cfg)
end

function M.focus()
  if not M.get_pane_id() then
    return
  end
  get_backend().focus(state)
end

---@param keys string[]
local function send_keys(keys)
  get_backend().send_keys(state, keys)
end

---@text string
local function default_format_keys(text)
  local chars = {}
  for char in text:gmatch(".") do
    if char == "\n" then
      table.insert(chars, "S-Enter")
    else
      table.insert(chars, char)
    end
  end
  return chars
end

local function format_keys(text)
  local provider = cfg.providers[cfg.provider]
  if provider.format_keys then
    return provider.format_keys(text)
  else
    return default_format_keys(text)
  end
end

---@param text string
---@param opts { submit: boolean }?
function M.send(text, opts)
  local transformed_text = require("agentmux.context").transform(text, {
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
  })

  if not M.get_pane_id() then
    vim.fn.setreg("+", transformed_text)
    vim.fn.setreg("*", transformed_text)
    vim.fn.setreg('"', transformed_text)
    vim.notify("Copied to clipboard", vim.log.levels.INFO)
    return
  end

  local backend = get_backend()
  if backend.send_text then
    backend.send_text(state, transformed_text, opts and opts.submit)
    return
  else
    local keys = format_keys(transformed_text)
    send_keys(keys)
  end

  if opts and opts.submit then
    send_keys({ "Enter" })
  end
end

---@param text string
---@param opts { submit: boolean, focus: boolean }?
function M.ask(text, opts)
  opts = opts or {}

  local highlight = require("agentmux.highlight")

  require("snacks").input({
    prompt = ("Ask %s"):format(cfg.provider),
    default = text,
    highlight = highlight,
    icon = "󰚩 ",
    win = {
      title_pos = "left",
      relative = "cursor",
      row = -3, -- Row above the cursor
      col = 0, -- Align with the cursor
      keys = {
        i_cr = {
          desc = "submit",
        },
      },
      b = {
        completion = true,
      },
      bo = {
        filetype = "agentmux_ask",
      },
      on_buf = function(win)
        vim.lsp.start(require("agentmux.cmp"), {
          bufnr = win.buf,
        })
      end,
    },
  }, function(input)
    if not input then
      return
    end
    M.send(input, opts)
    if opts.focus then
      M.focus()
    end
  end)
end

function M.pick_prompts()
  require("snacks").picker.select(cfg.prompts, {
    prompt = "pick prompt",
  }, function(item, _)
    if not item then
      return
    end
    M.send(item, { submit = true })
  end)
end

function M.get_providers()
  return vim.tbl_keys(cfg.providers or {})
end

function M.get_provider()
  return cfg.provider
end

---@param name string
function M.set_provider(name)
  if not cfg.providers[name] then
    vim.notify("Provider not found: " .. name, vim.log.levels.ERROR)
    return false
  end
  if M.is_active() then
    M.stop()
  end
  cfg.provider = name
  return true
end

return M
