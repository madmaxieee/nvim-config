local M = {}

-- Find the google3 root directory
---@param path string
---@return string?
function M.get_google3_root(path)
  -- If path contains /google3/, extract up to it
  local g3_index = path:find("/google3")
  if g3_index then
    return path:sub(1, g3_index + 7) -- Returns path ending with "/google3"
  end

  -- Check for CitC pattern: /google/src/cloud/<user>/<workspace>/
  local citc_pattern = "^(/google/src/cloud/[^/]+/[^/]+/)"
  local citc_root = path:match(citc_pattern)
  if citc_root then
    return citc_root .. "google3"
  end

  -- Fallback: traverse up looking for google3 directory
  local dir = vim.fn.fnamemodify(path, ":h")
  while dir ~= "/" do
    if vim.fn.isdirectory(dir .. "/google3") == 1 then
      return dir .. "/google3"
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end

  return nil
end

return M
