local M = {}

local find_jj_root = require("utils.jj").find_root

---@param opts snacks.picker.git.diff.Config
---@type snacks.picker.finder
local function jj_diff_finder(opts, ctx)
  opts = opts or {}

  local cwd = find_jj_root(ctx:cwd())
  ctx.picker:set_cwd(cwd)

  local Diff = require("snacks.picker.source.diff")
  ---@type snacks.picker.finder.result
  local finder = Diff.diff(
    ctx:opts({
      cmd = "jj",
      -- stylua: ignore
      args = {
        "--no-pager", "--color=never",
        "--config", "ui.diff-formatter=:git",
        "diff",
      },
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
    finder = jj_diff_finder,
    format = "git_status",
    preview = "diff",
  })
end

return M
