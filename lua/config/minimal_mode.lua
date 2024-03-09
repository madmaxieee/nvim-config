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
