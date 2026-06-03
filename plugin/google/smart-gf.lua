if not require("flags").in_google3 then
  return
end

local map = require("utils").safe_keymap_set
local gutils = require("gutils")

local G3_PREFIX = "google3/"

map({ "n", "x" }, "gf", function()
  local path
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\x16" then
    path = table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode }), "\n")
    path = path:gsub("^%s*(.-)%s*$", "%1")
  else
    path = vim.fn.expand("<cfile>")
  end

  if path:find(G3_PREFIX, nil, true) == 1 then
    local g3_root = gutils.get_google3_root(vim.fn.getcwd())
    path = path:sub(#G3_PREFIX + 1)
    path = vim.fs.joinpath(g3_root, path)
  end

  if vim.uv.fs_stat(path) then
    vim.cmd.edit(path)
  else
    vim.notify("Path does not exist: " .. path, vim.log.levels.WARN)
  end
end, {})
