local M = {}

M.config = {
  base_rev = "@-",
}

vim.api.nvim_create_user_command("JJDiff", function(opts)
  local rev = opts.args
  local path = vim.api.nvim_buf_get_name(0)
  local dir = vim.fs.dirname(path)
  vim.system(
    { "jj", "--no-pager", "--color=never", "log", "-r", rev, "--no-graph", "-T", "" },
    { cwd = dir },
    function(res)
      if res.code ~= 0 then
        vim.schedule(function()
          vim.notify(("jj: '%s' is not a valid rev"):format(rev))
        end)
        return
      end
      M.config.base_rev = rev
      local ok, make_source = pcall(require, "plugins.mini-diff.make-source")
      if ok then
        make_source.reload_all("jj")
      end
      vim.schedule(function()
        vim.notify(("jj: reference rev is set to '%s'"):format(rev))
      end)
    end
  )
end, { nargs = 1 })

vim.api.nvim_create_user_command("JJPDiff", function()
  if M.config.base_rev == "@-" then
    vim.cmd([[JJDiff @--]])
  else
    vim.cmd([[JJDiff @-]])
  end
end, { nargs = 0 })

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
