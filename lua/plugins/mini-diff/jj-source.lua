local find_jj_root = require("utils.jj").find_root
local make_source = require("plugins.mini-diff.make-source")

local jj_config = {
  base_rev = "@-",
}

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

  setup = function()
    vim.api.nvim_create_user_command("MiniJJDiff", function(opts)
      local rev = opts.args
      local path = vim.api.nvim_buf_get_name(0)
      local dir = vim.fs.dirname(path)
      vim.system(
        jj_cmd("log", "-r", rev, "--no-graph", "-T", ""),
        { cwd = dir },
        function(res)
          if res.code ~= 0 then
            vim.schedule(function()
              vim.notify(("mini.diff jj: '%s' is not a valid rev"):format(rev))
            end)
            return
          end
          jj_config.base_rev = rev
          make_source.reload_all("jj")
          vim.schedule(function()
            vim.notify(
              ("mini.diff jj: reference rev is set to '%s'"):format(rev)
            )
          end)
        end
      )
    end, { nargs = 1 })
    vim.api.nvim_create_user_command("MiniJJPDiff", function()
      if jj_config.base_rev == "@-" then
        vim.cmd([[MiniJJDiff @--]])
      else
        vim.cmd([[MiniJJDiff @-]])
      end
    end, { nargs = 0 })
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
