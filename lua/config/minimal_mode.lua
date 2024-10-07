vim.api.nvim_create_user_command("MinimalMode", function()
  vim.g.MinimalMode = 1
end, {})
vim.api.nvim_create_user_command("NoMinimalMode", function()
  vim.g.MinimalMode = 0
end, {})

if vim.g.MinimalMode == 1 then
  vim.g.minimal_mode = true
end

-- when nvim used by tmux scrollback buffer
if vim.env.TMUX_SCROLLBACK then
  vim.g.minimal_mode = true
  return
end

-- when nvim used by git to edit commit messages
if vim.env.GIT_EXEC_PATH then
  vim.g.minimal_mode = true
  return
end

-- when nvim is used by fish to edit command line
local argc = vim.fn.argc()
local argv = vim.fn.argv()
-- if on macos then argv will be like this:
-- { "/var/folders/pg/4v3k1ztx3bb8bm_mzw0hknqc0000gn/T/tmp.UDKOra60Bm.fish" }
-- { "/private/var/folders/pg/4v3k1ztx3bb8bm_mzw0hknqc0000gn/T/tmp.0jb32zqIvy.fish" }
if vim.fn.has "mac" == 1 then
  if argc == 1 and string.match(argv[1], "/var/folders/pg/.+/T/tmp%.%w+%.fish$") then
    vim.g.minimal_mode = true
    return
  end
end
if vim.fn.has "linux" == 1 then
  if argc == 1 and string.match(argv[1], "/tmp/tmp%.%w+%.fish$") then
    vim.g.minimal_mode = true
    return
  end
end

-- when nvim is used in vipe (my script)
if argc == 1 and string.match(argv[1], "/tmp/vipe%.[0-9]+%.txt$") then
  vim.g.minimal_mode = true
  return
end
