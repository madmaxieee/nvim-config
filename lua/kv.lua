local M = {}

local config_file = vim.fs.joinpath(vim.fn.stdpath("state"), "kv.json")

---@class Kv
---@field theme "dark" | "light"
---@field colorscheme string
---@field colorscheme_light string

---@alias KvKey "theme" | "colorscheme" | "colorscheme_light"

---@type KvKey[]
M.keys = { "theme", "colorscheme", "colorscheme_light" }

---@type Kv?
local config = nil

---@type Kv
local default_config = {
  theme = "dark",
  colorscheme = "tokyonight-moon",
  colorscheme_light = "catppuccin-latte",
}

---@return Kv
local function read_config()
  if not vim.uv.fs_access(config_file, "R") then
    return vim.deepcopy(default_config)
  end
  local ok, decoded = pcall(function()
    local json_str = vim.fn.readblob(config_file)
    return vim.json.decode(json_str)
  end)
  if ok and type(decoded) == "table" then
    return vim.tbl_deep_extend("force", vim.deepcopy(default_config), decoded)
  else
    vim.notify(
      "kv: Failed to read or decode config file: " .. tostring(decoded),
      vim.log.levels.ERROR
    )
    return vim.deepcopy(default_config)
  end
end

---@alias KvCallback fun(conf: Kv)

---@type table<KvKey, KvCallback[]>
local on_change_callbacks = {}

---@param keys KvKey | KvKey[]
---@param callback KvCallback
function M.on_change(keys, callback)
  if type(keys) == "string" then
    keys = { keys }
  end
  for _, key in ipairs(keys) do
    if not on_change_callbacks[key] then
      on_change_callbacks[key] = {}
    end
    on_change_callbacks[key][#on_change_callbacks[key] + 1] = callback
  end
end

local is_dirty = false

function M.reload()
  config = read_config()
  if config then
    is_dirty = false
    local seen = {}
    for _, callbacks in pairs(on_change_callbacks) do
      for _, callback in ipairs(callbacks) do
        if not seen[callback] then
          seen[callback] = true
          callback(config)
        end
      end
    end
  end
end

function M.is_loaded()
  return config ~= nil
end

---@param key KvKey?
function M.get(key)
  if not config then
    config = read_config()
  end
  if not config then
    return nil
  end
  if key == nil then
    return vim.deepcopy(config)
  end
  return config[key]
end

---@param key KvKey
---@param value any
function M.set(key, value)
  if not config then
    config = read_config()
  end
  config[key] = value
  is_dirty = true
  if config and on_change_callbacks[key] then
    for _, callback in ipairs(on_change_callbacks[key]) do
      callback(config)
    end
  end
end

function M.save()
  if is_dirty and config then
    local ok, json_str = pcall(vim.json.encode, config)
    if ok then
      local write_ok = pcall(vim.fn.writefile, { json_str }, config_file)
      if write_ok then
        is_dirty = false
      end
    end
  end
end

return M
