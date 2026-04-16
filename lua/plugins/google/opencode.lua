if not require("flags").on_glinux then
  return {}
end

local utils = require("utils")
local pane = require("opencode_pane")

---@param path string
---@return string?
local function get_credential_from_pass_sync(path)
  local result = vim
    .system({ "pass", path }, {
      env = { PASSWORD_STORE_GPG_OPTS = "--pinentry-mode cancel" },
      text = true,
    })
    :wait()
  if result.code ~= 0 then
    return nil
  else
    return vim.trim(result.stdout)
  end
end

---@param callback fun(passphrase: string)
local function get_pass_passphrase_from_op(callback)
  vim.system(
    { "op", "read", "op://personal/password-store/password" },
    function(res)
      if res.code ~= 0 then
        return
      end
      local passphrase = vim.trim(res.stdout)
      callback(passphrase)
    end
  )
end

---@param callback fun(passphrase: string)
local function get_pass_passphrase_from_input(callback)
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
    on_submit = function(value)
      callback(value)
    end,
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
end

---@param path string
---@param callback fun(api_key: string)
local function get_credential_from_pass(path, callback)
  local function unlock_pass(passphrase)
    vim.system({ "pass", path }, {
      env = {
        PASSWORD_STORE_GPG_OPTS = "--passphrase-fd 0 --pinentry-mode loopback",
      },
      stdin = passphrase,
    }, function(res)
      if res.code ~= 0 then
        vim.schedule(function()
          vim.notify("Can't unlock password store", vim.log.levels.ERROR)
        end)
        return
      end
      local api_key = vim.trim(res.stdout)
      vim.schedule(function()
        callback(api_key)
      end)
    end)
  end
  if vim.fn.executable("op") == 1 then
    get_pass_passphrase_from_op(unlock_pass)
  else
    get_pass_passphrase_from_input(unlock_pass)
  end
end

utils.on_load("opencode.nvim", function()
  vim.g.opencode_opts.server.start = function()
    local api_key = get_credential_from_pass_sync("gemini/cli")
    if api_key then
      pane.create_pane(api_key)
    else
      get_credential_from_pass("gemini/cli", function(key)
        pane.create_pane(key)
      end)
    end
  end
end)

return {}
