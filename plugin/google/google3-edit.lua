if not require("flags").in_google3 then
  return
end

local gutils = require("gutils")

vim.api.nvim_create_user_command("G3", function(args)
  local path = vim.trim(args.args)
  if path == "" then
    return
  end

  if
    not (
      path:find(gutils.G3_PREFIX, nil, true) == 1
      or path:find(gutils.DEPOT_PREFIX, nil, true) == 1
    )
  then
    path = gutils.G3_PREFIX .. path
  end

  path = gutils.google3_path_to_filesystem_path(path)
  vim.cmd.edit(path)
end, {
  nargs = 1,
  desc = "Edit a file in google3 by its relative path",
})
