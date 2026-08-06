if not require("flags").in_google3 then
  return
end

local gutils = require("gutils")
local map = require("utils").safe_keymap_set

---@param opts? { path?: string, line1?: integer, line2?: integer }
---@return string? url
local function create_and_copy_link(opts)
  opts = opts or {}

  local path = opts.path
  if not path or path == "" or path == "%" then
    path = vim.api.nvim_buf_get_name(0)
  end

  if path == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  if not (path:match("^//") or path:match("^google3/")) then
    path = vim.fs.normalize(vim.fs.abspath(path))
  end

  local rel_path = gutils.get_google3_relative_path(path)
  if not rel_path or rel_path == "" then
    vim.notify("File is not in google3", vim.log.levels.ERROR)
    return
  end

  local cl = gutils.get_sync_head_cl(path)
  if not cl then
    vim.notify("Could not determine sync head CL", vim.log.levels.WARN)
  end

  local line_str
  if opts.line1 and opts.line2 and opts.line1 ~= opts.line2 then
    line_str = string.format("%d-%d", opts.line1, opts.line2)
  elseif opts.line1 then
    line_str = tostring(opts.line1)
  elseif opts.line2 then
    line_str = tostring(opts.line2)
  else
    local cursor = vim.api.nvim_win_get_cursor(0)
    line_str = tostring(cursor[1])
  end

  local cl_part = cl and string.format(";cl=%s", cl) or ""
  local url =
    string.format("http://google3/%s%s;l=%s", rel_path, cl_part, line_str)

  -- Copy to clipboard (+ and * and default register ")
  vim.fn.setreg("+", url)
  vim.fn.setreg("*", url)
  vim.fn.setreg('"', url)

  vim.notify("Copied: " .. url, vim.log.levels.INFO)
  return url
end

vim.api.nvim_create_user_command("G3Link", function(opts)
  local path = vim.trim(opts.args or "")
  create_and_copy_link({
    path = path ~= "" and path or nil,
    line1 = opts.line1,
    line2 = opts.line2,
  })
end, {
  range = true,
  nargs = "?",
  complete = "file",
  desc = "Construct and copy shareable google3 link for current buffer/line",
})

map("n", "<leader>gl", function()
  create_and_copy_link()
end, { desc = "Copy google3 link" })

map("x", "<leader>gl", function()
  local line1 = vim.fn.line("'<")
  local line2 = vim.fn.line("'>")
  create_and_copy_link({ line1 = line1, line2 = line2 })
end, { desc = "Copy google3 link for selection" })
