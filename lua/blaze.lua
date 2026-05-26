local co2 = require("co2")
local M = {}

-- Helper: Check if a file exists
---@param path string
local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- Find the google3 root directory
---@param path string
---@return string?
local function get_google3_root(path)
  -- If path contains /google3/, extract up to it
  local g3_index = path:find("/google3")
  if g3_index then
    return path:sub(1, g3_index + 7) -- Returns path ending with "/google3"
  end

  -- Check for CitC pattern: /google/src/cloud/<user>/<workspace>/
  local citc_pattern = "^(/google/src/cloud/[^/]+/[^/]+/)"
  local citc_root = path:match(citc_pattern)
  if citc_root then
    return citc_root .. "google3"
  end

  -- Fallback: traverse up looking for google3 directory
  local dir = vim.fn.fnamemodify(path, ":h")
  while dir ~= "/" do
    if vim.fn.isdirectory(dir .. "/google3") == 1 then
      return dir .. "/google3"
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end

  return nil
end

-- Find nearest BUILD file upwards, stopping at g3_root
---@param path string
---@param g3_root string
function M.get_package_path(path, g3_root)
  if not g3_root then
    return nil
  end
  local dir = vim.fn.fnamemodify(path, ":h")
  while dir ~= "/" do
    if file_exists(dir .. "/BUILD") then
      return dir
    end
    if dir == g3_root then
      break
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

-- Convert disk path to blaze path (e.g. //foo/bar)
---@param disk_path string
---@param g3_root string
function M.disk_path_to_blaze_path(disk_path, g3_root)
  if disk_path == g3_root then
    return "//"
  end
  -- Strip g3_root from disk_path
  local rel_path = disk_path:sub(#g3_root + 2) -- +2 to skip the trailing slash
  return "//" .. rel_path
end

-- Run blaze query asynchronously and call callback with list of targets
---@param query string
---@param g3_root string
---@param callback fun(targets: string[])
local blaze_query = co2.wrap(function(ctx, query, g3_root, callback)
  local res = ctx.await(
    vim.system,
    { "blaze", "query", query },
    { cwd = g3_root }
  )
  local targets = {}
  if res.code == 0 and res.stdout then
    for line in res.stdout:gmatch("[^\r\n]+") do
      table.insert(targets, line)
    end
  end
  callback(targets)
end)

-- Infer Command (build vs test) based on filename
---@param filepath string
---@return "build"|"test"
local function infer_command(filepath)
  local basename = vim.fn.fnamemodify(filepath, ":t:r")
  if basename:lower():match("test$") then
    return "test"
  end
  return "build"
end

local get_all_affected_targets = co2.wrap(
  -- Run affected_targets and call callback with list of targets
  ---@param cmd_type "build"|"test"
  ---@param g3_root string
  ---@param callback fun(targets: string[]?)
  function(ctx, cmd_type, g3_root, callback)
    local res = ctx.await(vim.system, { "affected_targets" }, { cwd = g3_root })

    if res.code ~= 0 or not res.stdout then
      callback({})
      return
    end

    local targets = {}
    for line in res.stdout:gmatch("[^\r\n]+") do
      if
        cmd_type == "build"
        or (cmd_type == "test" and line:match("_test$"))
      then
        table.insert(targets, line)
      end
    end

    callback(targets)
  end
)

-- Main Entry Point: Infer targets for source files asynchronously
---@param filepath string
---@param cmd_type string
---@param callback fun(targets: string[]?)
local infer_targets = co2.wrap(function(ctx, filepath, cmd_type, callback)
  filepath = vim.fn.fnamemodify(filepath, ":p")

  -- Ensure we don't try to process BUILD files here
  local filename = vim.fn.fnamemodify(filepath, ":t")
  if
    filename == "BUILD"
    or filename == "BUILD.bazel"
    or vim.bo.filetype == "bzl"
  then
    callback(nil)
    return
  end

  local g3_root = get_google3_root(filepath)
  if not g3_root then
    callback(nil)
    return
  end

  local package_path = M.get_package_path(filepath, g3_root)
  if not package_path then
    callback(nil)
    return
  end

  local package_blaze_path = M.disk_path_to_blaze_path(package_path, g3_root)
  local file_blaze_path = package_blaze_path
    .. ":"
    .. vim.fn.fnamemodify(filepath, ":t")

  cmd_type = cmd_type or infer_command(filepath)

  local query
  if cmd_type == "test" then
    -- Java test package mapping (/java/ -> /javatests/)
    local test_package_blaze_path = package_blaze_path
    if filepath:find("/google3/java/") then
      test_package_blaze_path =
        package_blaze_path:gsub("//java/", "//javatests/")
    end

    local target_expr = test_package_blaze_path .. ":*"
    query = string.format(
      'kind(".*test rule", allpaths("%s", "%s")) - attr("tags", "\\bmanual\\b", kind(".*test rule", allpaths("%s", "%s")))',
      target_expr,
      file_blaze_path,
      target_expr,
      file_blaze_path
    )
  else
    -- Build command target inference
    local target_expr = package_blaze_path .. ":*"
    query = string.format(
      'attr("srcs", "%s", "%s") union attr("hdrs", "%s", "%s")',
      file_blaze_path,
      target_expr,
      file_blaze_path,
      target_expr
    )
  end

  local targets = ctx.await(blaze_query, query, g3_root)
  callback(targets)
end)

---@param cmd_type? "build"|"test"|"coverage"
---@param filepath? string
function M.blaze(cmd_type, filepath)
  filepath = filepath or vim.api.nvim_buf_get_name(0)
  if not filepath or filepath == "" then
    return
  end

  cmd_type = cmd_type or infer_command(filepath)
  vim.notify(
    ("Blaze %s running on %s..."):format(
      cmd_type,
      vim.fs.relpath(vim.fn.getcwd(), filepath)
    )
  )

  co2.run(function(ctx)
    local targets = ctx.await(infer_targets, filepath, cmd_type)
    if not targets or #targets == 0 then
      vim.schedule(function()
        vim.notify(
          "No blaze targets found for " .. filepath,
          vim.log.levels.WARN
        )
      end)
      return
    end

    local command = vim.list_extend({ "blaze", cmd_type }, targets)

    vim.schedule(function()
      require("snacks").terminal.open(command, {
        auto_close = false,
        interactive = false,
        win = {
          position = "bottom",
          height = 0.3,
        },
      })
    end)
  end)
end

---@param cmd_type "build"|"test"
function M.blaze_all(cmd_type)
  if cmd_type ~= "build" and cmd_type ~= "test" then
    vim.notify(
      "Invalid command type for blaze_all: " .. tostring(cmd_type),
      vim.log.levels.ERROR
    )
    return
  end

  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    filepath = vim.fn.getcwd()
  end

  local g3_root = get_google3_root(filepath)
  if not g3_root then
    vim.notify("Not in a google3 workspace", vim.log.levels.ERROR)
    return
  end

  vim.notify(("Blaze %s running on all affected targets..."):format(cmd_type))

  co2.run(function(ctx)
    local targets = ctx.await(get_all_affected_targets, cmd_type, g3_root)
    if not targets or #targets == 0 then
      vim.schedule(function()
        vim.notify("No affected blaze targets found", vim.log.levels.WARN)
      end)
      return
    end

    local command = vim.list_extend({ "blaze", cmd_type }, targets)

    vim.schedule(function()
      require("snacks").terminal.open(command, {
        auto_close = false,
        interactive = false,
        win = {
          position = "bottom",
          height = 0.3,
        },
      })
    end)
  end)
end

return M
