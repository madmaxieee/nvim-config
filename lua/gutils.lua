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

-- Find CitC root directory for a given path
---@param path? string
---@return string?
function M.get_citc_root(path)
  path = path or vim.fn.getcwd()
  path = require("utils").strip_oil_prefix(path)

  local citc_root = path:match("^(/google/src/cloud/[^/]+/[^/]+)")
  if citc_root then
    return citc_root
  end

  for dir in vim.fs.parents(path) do
    if vim.uv.fs_stat(vim.fs.joinpath(dir, ".citc")) then
      return dir
    end
  end

  return nil
end

-- Extract relative path from google3 root (e.g. "wireless/android/pixel/modem/ltp/mh/prepare_device.py")
---@param path? string
---@return string?
function M.get_google3_relative_path(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if not path or path == "" then
    return nil
  end

  path = require("utils").strip_oil_prefix(path)

  -- If depot path: //depot/google3/foo/bar
  local depot_g3 = path:match("^//depot/google3/(.+)$")
  if depot_g3 then
    return depot_g3
  end

  -- If path contains /google3/ (e.g. /google/src/cloud/.../google3/foo/bar or /google/src/files/head/depot/google3/foo/bar)
  local after_g3 = path:match("/google3/(.+)$")
  if after_g3 then
    return after_g3
  end

  -- If path starts with google3/ (e.g. google3/foo/bar)
  local starts_g3 = path:match("^google3/(.+)$")
  if starts_g3 then
    return starts_g3
  end

  -- If relative to google3 root
  local g3_root = M.get_google3_root(path)
  if g3_root then
    local abs_path = vim.fs.normalize(vim.fs.abspath(path))
    local norm_g3_root = vim.fs.normalize(g3_root)
    if vim.startswith(abs_path, norm_g3_root .. "/") then
      return abs_path:sub(#norm_g3_root + 2)
    end
  end

  return nil
end

-- Get sync head CL for a given path or buffer
---@param path? string
---@return string?
function M.get_sync_head_cl(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if not path or path == "" then
    path = vim.fn.getcwd()
  end
  path = require("utils").strip_oil_prefix(path)

  -- 1. Check CitC workspace metadata (.citc/srcfs_workspace.ascii)
  local citc_root = M.get_citc_root(path)
  if citc_root then
    local ascii_path =
      vim.fs.joinpath(citc_root, ".citc", "srcfs_workspace.ascii")
    local f = io.open(ascii_path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      local cl = content:match("change:%s*(%d+)")
      if cl then
        return cl
      end
    end

    -- Try srcfs command
    if vim.fn.executable("srcfs") == 1 then
      local out = vim.fn.system({
        "srcfs",
        "--client_root=" .. citc_root,
        "get_readonly",
      })
      if vim.v.shell_error == 0 then
        local cl = vim.trim(out):match("^(%d+)")
        if cl then
          return cl
        end
      end
    end
  end

  -- 2. Try JJ if inside a jj repo
  if vim.fn.executable("jj") == 1 then
    local jj_args =
      { "jj", "log", "-r", "p4head", "--no-graph", "-T", "description" }
    if citc_root then
      table.insert(jj_args, "-R")
      table.insert(jj_args, citc_root)
    end
    local out = vim.fn.system(jj_args)
    if vim.v.shell_error == 0 then
      local cl = out:match("OCL=(%d+)")
        or out:match("cl/(%d+)")
        or out:match("Change%s+(%d+)")
      if cl then
        return cl
      end
    end
  end

  -- 3. Fallback: g4 / p4 submitted change
  if vim.fn.executable("g4") == 1 then
    local out = vim.fn.system({ "g4", "changes", "-m", "1", "-s", "submitted" })
    if vim.v.shell_error == 0 then
      local cl = out:match("Change%s+(%d+)")
      if cl then
        return cl
      end
    end
  elseif vim.fn.executable("p4") == 1 then
    local out = vim.fn.system({ "p4", "changes", "-m", "1", "-s", "submitted" })
    if vim.v.shell_error == 0 then
      local cl = out:match("Change%s+(%d+)")
      if cl then
        return cl
      end
    end
  end

  return nil
end

return M
