if not require("flags").on_glinux then
  return {}
end

local co2 = require("co2")
local utils = require("utils")
local pane = require("opencode_pane")

---@param ctx Co2Context
local function get_pass_passphrase(ctx)
  if vim.fn.executable("op") == 1 then
    local res = ctx.await(
      vim.system,
      { "op", "read", "op://personal/password-store/password" },
      { text = true }
    )
    if res.code ~= 0 then
      return
    end
    return vim.trim(res.stdout)
  end

  local SecretInput = require("plugins.nui.secret_input")
  local event = require("nui.utils.autocmd").event

  local input = SecretInput({
    relative = "editor",
    position = "50%",
    size = { width = 40 },
    border = {
      style = "rounded",
      text = {
        top = "[unlock password store]",
        top_align = "center",
      },
    },
  }, {
    on_submit = ctx.resume,
  })

  input:map("n", "<Esc>", function()
    input:unmount()
  end, { noremap = true })

  input:on(event.BufLeave, function()
    input:unmount()
  end)

  input:on(event.BufEnter, function()
    vim.cmd("startinsert")
  end)

  input:mount()
  return ctx.yield()
end

---@param ctx Co2Context
---@param path string
---@return string?
local function get_credential_from_pass(ctx, path)
  local passphrase = get_pass_passphrase(ctx)
  if not passphrase then
    return
  end

  local res = ctx.await(vim.system, { "pass", path }, {
    text = true,
    stdin = passphrase,
    env = {
      PASSWORD_STORE_GPG_OPTS = "--passphrase-fd 0 --pinentry-mode loopback",
    },
  })

  if res.code ~= 0 then
    vim.notify("Can't unlock password store", vim.log.levels.ERROR)
    return
  end

  return vim.trim(res.stdout)
end

utils.on_load("opencode.nvim", function()
  vim.g.opencode_opts.server.start = co2.wrap(function(ctx)
    vim.notify("Starting opencode server...", vim.log.levels.INFO)
    local api_key = get_credential_from_pass(ctx, "gemini/cli")
    if api_key then
      pane.create_pane(api_key)
    end
  end)
end)

return {}
