---@alias DiffCacheEntry {fs_event:uv.uv_fs_event_t, timer:uv.uv_timer_t, attached?:string}

---@type table<integer, DiffCacheEntry>
local cache = {}

---@param cache_entry DiffCacheEntry?
local function cleanup(cache_entry)
  if cache_entry == nil then
    return
  end
  pcall(vim.uv.fs_event_stop, cache_entry.fs_event)
  pcall(vim.uv.timer_stop, cache_entry.timer)
end

---@class WatchPattern
---@field dir string
---@field file string

---@class DiffSourceOpts
---@field name                  string
---@field should_enable?        fun(): boolean
---@field setup?                fun()
---@field async_find_root       fun(path: string, callback: fun(root: string?))
---@field root_to_watch_pattern fun(root: string): WatchPattern
---@field async_get_ref_text    fun(path: string, callback: fun(text: string|string[]))

---@type fun(buf: integer, text: string|string[])
local set_ref_text = vim.schedule_wrap(function(buf, text)
  local ok, err = pcall(require("mini.diff").set_ref_text, buf, text)
  if not ok and err then
    vim.notify(err)
  end
end)

---@type fun(buf: integer)
local fail_attach = vim.schedule_wrap(function(buf)
  local ok, err = pcall(require("mini.diff").fail_attach, buf)
  if not ok and err then
    vim.notify(err)
  end
end)

---@param buf integer
local function get_buf_realpath(buf)
  return vim.uv.fs_realpath(vim.api.nvim_buf_get_name(buf))
end

---@param buf integer used as the cache key
---@param watch_pattern WatchPattern
---@param callback fun()
local function start_watching(buf, watch_pattern, callback)
  local buf_fs_event = vim.uv.new_fs_event()
  if not buf_fs_event then
    vim.notify("Could not create new_fs_event")
    return
  end

  local timer = vim.uv.new_timer()
  if not timer then
    vim.notify("Could not create new_timer")
    buf_fs_event:stop()
    return
  end

  local debounced_cb = function(_, filename, _)
    if watch_pattern.file and filename ~= watch_pattern.file then
      return
    end
    timer:stop()
    timer:start(50, 0, callback)
  end
  timer:start(0, 0, callback)

  buf_fs_event:start(watch_pattern.dir, { recursive = false }, debounced_cb)
  cleanup(cache[buf])
  cache[buf].fs_event = buf_fs_event
  cache[buf].timer = timer
end

---@param opts DiffSourceOpts
local function make_diff_source(opts)
  if not opts.should_enable then
    opts.should_enable = function()
      return true
    end
  end

  local name = opts.name

  if vim.fn.executable(name) ~= 1 or not opts.should_enable() then
    return {
      name = name,
      attach = function()
        return false
      end,
      detach = function(_) end,
    }
  end

  if opts.setup then
    opts.setup()
  end

  return {
    name = name,

    ---@param buf integer
    attach = function(buf)
      if cache[buf] ~= nil then
        return false
      end
      local path = get_buf_realpath(buf)
      if not path then
        return false
      end

      cache[buf] = { attached = name }

      local function fs_callback()
        opts.async_get_ref_text(path, function(text)
          set_ref_text(buf, text)
        end)
      end
      opts.async_find_root(path, function(root)
        if root then
          local watch_pattern = opts.root_to_watch_pattern(root)
          start_watching(buf, watch_pattern, fs_callback)
        else
          fail_attach(buf)
        end
      end)
    end,

    ---@param buf integer
    detach = function(buf)
      if cache[buf].attached == name then
        cleanup(cache[buf])
        cache[buf] = nil
      end
    end,
  }
end

local hg_config = {
  base_rev = ".",
}

local function hg_cmd(...)
  local HG = {
    "hg",
    "--pager=never",
    "--color=never",
  }
  return vim.list_extend(HG, { ... })
end

---@type DiffSourceOpts
local hg_opts = {
  name = "hg",

  should_enable = function()
    return require("modes").google3_mode
  end,

  setup = function()
    vim.api.nvim_create_user_command("MiniHgDiff", function(opts)
      local rev = opts.args
      local path = vim.api.nvim_buf_get_name(0)
      local dir = vim.fn.fnamemodify(path, ":h")
      vim.system(hg_cmd("identify", "--rev", rev), { cwd = dir }, function(res)
        if res.code ~= 0 then
          vim.schedule(function()
            vim.notify(("mini.diff hg: '%s' is not a valid rev"):format(rev))
          end)
          return
        end
        hg_config.base_rev = rev
        for buf, entry in pairs(cache) do
          if entry.attached == "hg" then
            vim.schedule(function()
              require("mini.diff").disable(buf)
              require("mini.diff").enable(buf)
              vim.notify(
                ("mini.diff hg: reference rev is set to '%s'"):format(rev)
              )
            end)
          end
        end
      end)
    end, { nargs = 1 })
    vim.api.nvim_create_user_command("MiniHgPDiff", function()
      if hg_config.base_rev == "." then
        vim.cmd([[MiniHgDiff .^]])
      else
        vim.cmd([[MiniHgDiff .]])
      end
    end, { nargs = 0 })
  end,

  root_to_watch_pattern = function(root)
    return { dir = root .. "/.hg", file = "dirstate" }
  end,

  async_find_root = function(path, callback)
    local dir = vim.fn.fnamemodify(path, ":h")
    vim.system(hg_cmd("root"), { cwd = dir }, function(res)
      if res.code ~= 0 then
        callback(nil)
        return
      end
      local output = res.stdout or ""
      local root = vim.trim(output)
      if not root or root == "" then
        callback(nil)
        return
      end
      callback(root)
    end)
  end,

  async_get_ref_text = function(path, callback)
    local dir = vim.fn.fnamemodify(path, ":h")
    local basename = vim.fn.fnamemodify(path, ":t")
    vim.system(
      hg_cmd("cat", "--rev", hg_config.base_rev, "--", basename),
      { cwd = dir },
      function(res)
        if res.code ~= 0 then
          return
        end
        local output = res.stdout or ""
        callback(output)
      end
    )
  end,
}

local function jj_cmd(...)
  local JJ = {
    "jj",
    "--no-pager",
    "--color=never",
    "--ignore-working-copy",
  }
  return vim.list_extend(JJ, { ... })
end

---@type DiffSourceOpts
local jj_opts = {
  name = "jj",

  root_to_watch_pattern = function(root)
    return { dir = root .. "/.jj/working_copy", file = "checkout" }
  end,

  async_find_root = function(path, callback)
    local dir = vim.fn.fnamemodify(path, ":h")
    vim.system(jj_cmd("root"), { cwd = dir }, function(res)
      if res.code ~= 0 then
        callback(nil)
        return
      end
      local output = res.stdout or ""
      local root = vim.trim(output)
      if not root or root == "" then
        callback(nil)
        return
      end
      callback(root)
    end)
  end,

  async_get_ref_text = function(path, callback)
    local dir = vim.fn.fnamemodify(path, ":h")
    local basename = vim.fn.fnamemodify(path, ":t")
    vim.system(
      jj_cmd("file", "show", "-r", "@-", "--", basename),
      { cwd = dir },
      function(res)
        if res.code ~= 0 then
          return
        end
        local output = res.stdout or ""
        callback(output)
      end
    )
  end,
}

return {
  hg = function()
    return make_diff_source(hg_opts)
  end,
  jj = function()
    return make_diff_source(jj_opts)
  end,
}
