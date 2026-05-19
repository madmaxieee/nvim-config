---@class AgentMuxOptions
---@field provider string
---@field tmux_return_focus_key? string keybinding to return focus to the vim pane (default: "C-.")
---@field orientation? "horizontal" | "vertical" split orientation (default: "horizontal")
---@field percentage? integer split percentage 1-100 (default: 35)
---@field on_pane_created? fun(pane_id: string) callback that is called after the pane is created with the pane id as argument

---@class AgentMuxProvider
---@field command string
---@field env table<string, string>?
---@field stop_agent fun(pane_id: string)
---@field on_pane_created? fun(pane_id: string)

---@class AgentMuxConfig : AgentMuxOptions
---@field providers table<string, AgentMuxProvider>

---@type AgentMuxConfig
local config = {
  provider = "opencode",
  tmux_return_focus_key = "C-.",
  orientation = "horizontal",
  percentage = 35,
  providers = {
    opencode = {
      command = "exec opencode --port",
      stop_agent = function(pane_id)
        -- stylua: ignore
        vim.system({
          "tmux", "send-keys", "-t", pane_id,
          -- clear prompt then exit opencode
          "C-c", "/exit",
        })
      end,
    },
  },
}

---@type {pane_id:string?}
local state = {}

local M = {}

---@param opts AgentMuxOptions
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", opts, opts or {})
end

function M.is_active()
  return M.get_pane_id() ~= nil
end

function M.get_pane_id()
  if state.pane_id then
    local res = vim.system({ "tmux", "list-panes", "-t", state.pane_id }):wait()
    if res.code ~= 0 then
      state.pane_id = nil
    end
  end
  return state.pane_id
end

---@param opts AgentMuxOptions?
function M.start(opts)
  if M.get_pane_id() then
    return
  end

  opts = vim.tbl_deep_extend("keep", config, opts or {})
  local provider = opts.providers[opts.provider]

  -- stylua: ignore
  local CREATE_PANE_CMD = {
    -- create a new pane
    "tmux", "split-window",
    -- print the pane id to stdout so we can capture it
    "-P", "-F", "#{pane_id}",
    -- split orientation and percentage
    opts.orientation == "horizontal" and "-h" or "-v",
    "-p", tostring(opts.percentage),
    -- the coding agent command
    provider.command,
  }

  local res = vim.system(CREATE_PANE_CMD, { env = provider.env }):wait()
  if res.code ~= 0 then
    vim.notify(
      "Failed to create coding agent pane: " .. res.stderr,
      vim.log.levels.ERROR
    )
    return
  end

  state.pane_id = vim.trim(res.stdout)

  if opts.on_pane_created then
    opts.on_pane_created(state.pane_id)
  end

  -- stylua: ignore
  vim.system({
    "tmux", "set-option", "-t", state.pane_id,
    "-p", "@agent-mux-pane", vim.env.TMUX_PANE,
  })
  -- stylua: ignore
  vim.system({
    "tmux", "bind-key", "-n", opts.tmux_return_focus_key,
    "if-shell", "-F", "#{?#{@agent-mux-pane},1,0}",
    [[ run-shell 'tmux select-pane -t "#{@agent-mux-pane}"' ]],
    ("send-keys %s"):format(opts.tmux_return_focus_key),
  })
end

function M.stop()
  local pane_id = M.get_pane_id()
  if not pane_id then
    return
  end

  local provider = config.providers[config.provider]
  provider.stop_agent(pane_id)

  -- unbind the keybinding
  vim.system({ "tmux", "unbind-key", "-n", config.tmux_return_focus_key })
end

function M.focus()
  local pane_id = M.get_pane_id()
  if not pane_id then
    return
  end
  vim.system({ "tmux", "select-pane", "-t", pane_id })
end

---@param pane_id string
---@param keys string[]
local function send_keys(pane_id, keys)
  local cmd = { "tmux", "send-keys", "-t", pane_id }
  vim.list_extend(cmd, keys)
  vim.system(cmd)
end

---@param str string
---@return string[]
local function string_to_char_list(str)
  local chars = {}
  for char in str:gmatch(".") do
    table.insert(chars, char)
  end
  return chars
end

---@param text string
---@param opts { submit: boolean }?
function M.send(text, opts)
  local pane_id = M.get_pane_id()
  if not pane_id then
    vim.notify("Agent pane is not active", vim.log.levels.WARN)
    return
  end

  local transformed_text = require("agentmux.context").transform(text, {
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
  })

  send_keys(pane_id, string_to_char_list(transformed_text))

  if opts and opts.submit then
    send_keys(pane_id, { "Enter" })
  end
end

---@param text string
---@param opts { submit: boolean, focus: boolean }?
function M.ask(text, opts)
  if not M.is_active() then
    vim.notify("Agent pane is not active", vim.log.levels.WARN)
    return
  end

  opts = opts or {}

  require("snacks").input({
    prompt = ("Ask %s:"):format(config.provider),
    default = text,
    snacks = {
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
      },
    },
  }, function(input)
    if not input then
      return
    end
    M.send(input, opts)
  end)
end

return M
