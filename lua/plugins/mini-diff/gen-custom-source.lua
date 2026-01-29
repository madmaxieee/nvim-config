---@alias DiffCacheEntry {fs_event:uv.uv_fs_event_t, timer:uv.uv_timer_t, attached?:string}

---@type table<integer, DiffCacheEntry>
local cache = {}

---@param cache_entry DiffCacheEntry?
local function invalidate(cache_entry)
  if cache_entry == nil then
    return
  end
  pcall(vim.uv.fs_event_stop, cache_entry.fs_event)
  pcall(vim.uv.timer_stop, cache_entry.timer)
end

---@alias AsyncGetRefTextFunc fun(path: string, callback: fun(text: string[]))

---@class WatchPath
---@field root string
---@field file string

---@class DiffSourceOpts
---@field name               string
---@field should_enable?     fun(): boolean
---@field async_check_path   fun(path: string, callback: fun(result:boolean, watch_path?:WatchPath))
---@field async_get_ref_text AsyncGetRefTextFunc

---@param buf integer
---@param text string[]
local set_ref_text = vim.schedule_wrap(function(buf, text)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  require("mini.diff").set_ref_text(buf, text)
end)

---@param buf integer
---@param path string
---@param watch_path WatchPath
---@param async_get_ref_text AsyncGetRefTextFunc
local function setup_fs_watcher(buf, path, watch_path, async_get_ref_text)
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

  local do_update = function()
    async_get_ref_text(path, function(text)
      set_ref_text(buf, text)
    end)
  end
  local debounced_update = function(_, filename, _)
    if watch_path.file and filename ~= watch_path.file then
      return
    end
    -- Debounce to not overload during incremental staging (like in script)
    timer:stop()
    timer:start(50, 0, do_update)
  end
  timer:start(0, 0, do_update)

  buf_fs_event:start(watch_path.root, { recursive = false }, debounced_update)
  invalidate(cache[buf])
  cache[buf] = { fs_event = buf_fs_event, timer = timer }
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
      attach = function(buf)
        require("mini.diff").fail_attach(buf)
      end,
      detach = function(_) end,
    }
  end

  return {
    name = name,

    ---@param buf integer
    attach = function(buf)
      cache[buf] = cache[buf] or {}
      if cache[buf].attached ~= nil then
        return false
      end
      cache[buf].attached = name
      if not vim.api.nvim_buf_is_valid(buf) then
        cache[buf] = nil
        return
      end
      local path = vim.api.nvim_buf_get_name(buf)
      opts.async_check_path(
        path,
        vim.schedule_wrap(function(found, watch_path)
          if not found then
            require("mini.diff").fail_attach(buf)
          else
            setup_fs_watcher(buf, path, watch_path, opts.async_get_ref_text)
          end
        end)
      )
    end,

    ---@param buf integer
    detach = function(buf)
      if cache[buf].attached == name then
        invalidate(cache[buf])
        cache[buf] = nil
      end
    end,
  }
end

---@type DiffSourceOpts
local hg_opts = {
  name = "hg",

  should_enable = function()
    return require("modes").google3_mode
  end,

  async_check_path = function(path, callback)
    local dir = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(dir) ~= 1 then
      return
    end
    vim.system({
      "hg",
      "--pager=never",
      "--color=never",
      "root",
    }, { cwd = dir }, function(res)
      if res.code ~= 0 then
        callback(false)
        return
      end
      local output = res.stdout or ""
      local hg_root = vim.trim(output)
      if not hg_root or hg_root == "" then
        callback(false)
        return
      end
      callback(true, { root = hg_root .. "/.hg", file = "dirstate" })
    end)
  end,

  async_get_ref_text = function(path, callback)
    local dir = vim.fn.fnamemodify(path, ":h")
    local basename = vim.fn.fnamemodify(path, ":t")
    if vim.fn.isdirectory(dir) ~= 1 then
      return
    end
    vim.system({
      "hg",
      "--pager=never",
      "--color=never",
      "cat",
      "--rev",
      ".",
      "--",
      basename,
    }, { cwd = dir }, function(res)
      if res.code ~= 0 then
        return
      end
      local output = res.stdout or ""
      local lines = vim.split(output, "\n", { plain = true })
      callback(lines)
    end)
  end,
}

---@type DiffSourceOpts
local jj_opts = {
  name = "jj",

  should_enable = function()
    return true
  end,

  async_check_path = function(path, callback)
    local dir = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(dir) ~= 1 then
      return
    end
    vim.system({
      "jj",
      "--no-pager",
      "--color=never",
      "--ignore-working-copy",
      "root",
    }, { cwd = dir }, function(res)
      if res.code ~= 0 then
        callback(false)
        return
      end
      local output = res.stdout or ""
      local jj_root = vim.trim(output)
      if not jj_root or jj_root == "" then
        callback(false)
        return
      end
      callback(
        true,
        { root = jj_root .. "/.jj/working_copy", file = "checkout" }
      )
    end)
  end,

  async_get_ref_text = function(path, callback)
    local dir = vim.fn.fnamemodify(path, ":h")
    local basename = vim.fn.fnamemodify(path, ":t")
    if vim.fn.isdirectory(dir) ~= 1 then
      return
    end
    vim.system({
      "jj",
      "--no-pager",
      "--color=never",
      "--ignore-working-copy",
      "file",
      "show",
      "-r",
      "@-",
      "--",
      basename,
    }, { cwd = dir }, function(res)
      if res.code ~= 0 then
        return
      end
      local output = res.stdout or ""
      local lines = vim.split(output, "\n", { plain = true })
      callback(lines)
    end)
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
