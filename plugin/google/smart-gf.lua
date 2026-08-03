if not require("flags").in_google3 then
  return
end

local map = require("utils").safe_keymap_set
local gutils = require("gutils")

map({ "n", "x" }, "gf", function()
  local path
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\x16" then
    path = table.concat(
      vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode }),
      "\n"
    )
    path = path:gsub("^%s*(.-)%s*$", "%1")
  else
    path = vim.fn.expand("<cfile>")
  end

  path = gutils.google3_path_to_filesystem_path(path)

  if vim.uv.fs_stat(path) then
    vim.cmd.edit(path)
  else
    vim.notify("Path does not exist: " .. path, vim.log.levels.WARN)
  end
end, {})
