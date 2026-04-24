local M = {}

---@type table<string, boolean>
local jj_root_cache = {}
---@param dir string
---@return boolean
local function is_jj_root(dir)
  if jj_root_cache[dir] == nil then
    local stat = vim.uv.fs_stat(dir .. "/.jj")
    jj_root_cache[dir] = (stat ~= nil) and (stat.type == "directory")
  end
  return jj_root_cache[dir]
end

--- Gets the jj root directory for a buffer or path.
--- Defaults to the current buffer.
---@param path? number|string buffer or path
---@return string?
function M.find_root(path)
  path = path or 0
  path = type(path) == "number" and vim.api.nvim_buf_get_name(path) or path --[[@as string]]
  path = path == "" and vim.uv.cwd() or path
  path = vim.fs.normalize(path)

  if is_jj_root(path) then
    return path
  end

  for dir in vim.fs.parents(path) do
    if is_jj_root(dir) then
      return vim.fs.normalize(dir)
    end
  end

  return nil
end

return M
