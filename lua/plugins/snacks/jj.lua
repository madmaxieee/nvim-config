local M = {}

local function jj_args(...)
  local args = {
    "--no-pager",
    "--color=never",
    "--ignore-working-copy",
  }
  return vim.list_extend(args, { ... })
end

local jj_cache = {} ---@type table<string, boolean>
---@param dir string
local function is_jj_root(dir)
  if jj_cache[dir] == nil then
    jj_cache[dir] = vim.uv.fs_stat(dir .. "/.jj") ~= nil
  end
  return jj_cache[dir]
end

--- Gets the git root for a buffer or path.
--- Defaults to the current buffer.
---@param path? number|string buffer or path
---@return string?
function M.get_root(path)
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

---@param opts snacks.picker.git.diff.Config
---@type snacks.picker.finder
local function jj_diff_finder(opts, ctx)
  opts = opts or {}
  local args = jj_args("--config", "ui.diff-formatter=:git", "diff")

  local cwd = M.get_root(ctx:cwd())
  ctx.picker:set_cwd(cwd)

  local Diff = require("snacks.picker.source.diff")
  ---@type snacks.picker.finder.result
  local finder = Diff.diff(
    ctx:opts({
      cmd = "jj",
      args = args,
      cwd = cwd,
    }),
    ctx
  )

  return function(cb)
    local items = {} ---@type snacks.picker.finder.Item[]
    finder(function(item)
      item.staged = false
      items[#items + 1] = item
    end)
    table.sort(items, function(a, b)
      if a.file ~= b.file then
        return a.file < b.file
      end
      return a.pos[1] < b.pos[1]
    end)
    for _, item in ipairs(items) do
      cb(item)
    end
  end
end

function M.diff()
  local picker = require("snacks.picker")
  ---@type snacks.picker.git.diff.Config
  picker.pick({
    title = "Jujutsu Diff",
    source = "git_diff",
    finder = jj_diff_finder,
  })
end

return M
