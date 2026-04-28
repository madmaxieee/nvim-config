local find_jj_root = require("utils.jj").find_root
local jj_config = require("utils.jj").config
local make_source = require("plugins.mini-diff.make-source")
local co2 = require("co2")

local function jj_cmd(...)
  local JJ = {
    "jj",
    "--no-pager",
    "--color=never",
  }
  return vim.list_extend(JJ, { ... })
end

---@type DiffSourceOpts
local jj_opts = {
  name = "jj",

  should_enable = function()
    return find_jj_root(vim.uv.cwd()) ~= nil
  end,

  root_to_watch_pattern = function(root)
    return { dir = root .. "/.jj/working_copy", file = "checkout" }
  end,

  get_root = find_jj_root,

  async_get_ref_text = co2.wrap(function(ctx, path, callback)
    local dir = vim.fs.dirname(path)
    local file = vim.fs.basename(path)

    local res = ctx.await(
      vim.system,
      jj_cmd(
        "--ignore-working-copy",
        "file",
        "show",
        "-r",
        jj_config.base_rev,
        "--",
        file
      ),
      { cwd = dir }
    )

    if res.code == 0 then
      local output = res.stdout or ""
      callback(output)
      return
    end

    -- If missing from base revision, check working copy (@) to differentiate
    -- between new files (diff against empty string) and ignored files (do nothing).
    local res2 = ctx.await(
      vim.system,
      jj_cmd("file", "show", "-r", "@", "--", file),
      { cwd = dir }
    )
    if res2.code == 0 then
      callback("")
    end
  end),
}

return function()
  return make_source.make_diff_source(jj_opts)
end
