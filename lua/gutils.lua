local M = {}

M.G3_PREFIX = "google3/"
M.DEPOT_PREFIX = "//depot/"

-- Find the google3 root directory
---@param path? string
---@return string?
function M.get_google3_root(path)
  path = path or vim.fn.getcwd()

  -- If path contains /google3/, extract up to it
  local g3_index = path:find("/google3(/|$)")
  if g3_index then
    return path:sub(1, g3_index + 7) -- Returns path ending with "/google3"
  end

  -- Check for CitC pattern: /google/src/cloud/<user>/<workspace>/
  local citc_root = path:match("^(/google/src/cloud/[^/]+/[^/]+).*")
  if citc_root then
    return vim.fs.joinpath(citc_root, "google3")
  end

  -- Fallback: traverse up the tree looking for google3 directory
  for dir in vim.fs.parents(path) do
    if vim.fs.basename(dir) == "google3" then
      return dir
    end
  end

  return nil
end

-- Convert a google3 or depot relative path to a normal filesystem path
---@param path string
---@param g3_root? string
---@return string
function M.google3_path_to_filesystem_path(path, g3_root)
  g3_root = g3_root or M.get_google3_root()
  if not g3_root then
    return path
  end

  if path:find(M.G3_PREFIX, nil, true) == 1 then
    path = path:sub(#M.G3_PREFIX + 1)
    path = vim.fs.joinpath(g3_root, path)
  elseif path:find(M.DEPOT_PREFIX, nil, true) == 1 then
    local depot_root = vim.fs.normalize(vim.fs.joinpath(g3_root, ".."))
    path = path:sub(#M.DEPOT_PREFIX + 1)
    path = vim.fs.joinpath(depot_root, path)
  end

  return path
end

return M
