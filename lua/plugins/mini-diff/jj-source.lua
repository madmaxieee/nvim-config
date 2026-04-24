local find_jj_root = require("utils.jj").find_root
local jj_config = require("utils.jj").config
local make_source = require("plugins.mini-diff.make-source")

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

  async_get_ref_text = function(path, callback)
    local dir = vim.fs.dirname(path)
    local file = vim.fs.basename(path)
    vim.system(
      jj_cmd(
        "--ignore-working-copy",
        "file",
        "show",
        "-r",
        jj_config.base_rev,
        "--",
        file
      ),
      { cwd = dir },
      function(res)
        if res.code ~= 0 then
          callback("")
          return
        end
        local output = res.stdout or ""
        callback(output)
      end
    )
  end,
}

return function()
  return make_source.make_diff_source(jj_opts)
end
