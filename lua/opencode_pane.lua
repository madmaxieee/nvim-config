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

function M.get_provider()
  return provider
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
  vim.system(OPENCODE_PANE_CMD, env and { env = env } or {}, function(res)
    if res.code ~= 0 then
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
    -- mark this pane as the opencode pane
    -- stylua: ignore
    vim.system({
      "tmux", "set-option", "-t", provider.pane_id,
      "-p", "@opencode-pane", "1",
    })
    -- set up tmux binding: Ctrl-. in opencode pane zooms the neovim pane,
    -- otherwise passes through to the application (e.g. neovim)
    -- stylua: ignore
    vim.system({
      "tmux", "bind-key", "-n", "C-.",
      "if-shell", "-F", "#{==:#{@opencode-pane},1}",
      "resize-pane -Z",
      "send-keys C-.",
    })
  end)
end

return M
