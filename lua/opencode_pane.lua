---@type {pane_id:string?}
local provider = {}

local M = {}

function M.get_pane_id()
  if provider.pane_id then
    local res = vim
      .system({
        "tmux",
        "list-panes",
        "-t",
        provider.pane_id,
      })
      :wait()
    if res.code ~= 0 then
      provider.pane_id = nil
    end
  end
  return provider.pane_id
end

function M.clear_pane_id()
  provider.pane_id = nil
end

---@param api_key string?
function M.create_pane(api_key)
  if M.get_pane_id() then
    return
  end
  -- stylua: ignore
  local OPENCODE_PANE_CMD = {
    -- create a new pain in detached mode (no focus)
    "tmux", "split-window", "-d",
    -- print the pane id to stdout so we can capture it
    "-P", "-F", "#{pane_id}",
    -- split horizontally and set the width to 35% of the screen
    "-h", "-p", "35",
    -- the opencode command
    "exec opencode --port",
  }
  local env = api_key and { GEMINI_API_KEY = api_key } or nil
  local res = vim.system(OPENCODE_PANE_CMD, { env = env }):wait()
  if res.code ~= 0 then
    vim.notify(
      "Failed to create opencode pane: " .. res.stderr,
      vim.log.levels.ERROR
    )
    return
  end
  provider.pane_id = vim.trim(res.stdout)
  -- stylua: ignore
  vim.system({
    -- target the pane we just created
    "tmux", "set-option", "-t", provider.pane_id,
    -- disable allow-passthrough so the terminal does not send escape code
    -- to the vim pane
    "-p", "allow-passthrough", "off",
  })
  -- stylua: ignore
  vim.system({
    "tmux", "set-option", "-t", provider.pane_id,
    "-p", "@opencode-nvim-pane", vim.env.TMUX_PANE,
  })
  -- stylua: ignore
  vim.system({
    "tmux", "bind-key", "-n", "C-.",
    "if-shell", "-F", "#{?#{@opencode-nvim-pane},1,0}",
    [[ run-shell 'tmux select-pane -t "#{@opencode-nvim-pane}"' ]],
    "send-keys C-.",
  })
end

return M
