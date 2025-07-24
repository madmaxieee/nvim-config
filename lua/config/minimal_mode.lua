local function is_minimal_mode()
  -- when nvim used by tmux scrollback buffer
  if vim.env.TMUX_SCROLLBACK then
    return true
  end

  -- when nvim used by git to edit commit messages
  if vim.env.GIT_EXEC_PATH then
    return true
  end

  -- when nvim is used by fish to edit command line
  local argc = vim.fn.argc()
  local argv = vim.fn.argv()
  -- if on macos then argv will be like this:
  -- { "/var/folders/pg/4v3k1ztx3bb8bm_mzw0hknqc0000gn/T/tmp.UDKOra60Bm.fish" }
  -- { "/private/var/folders/pg/4v3k1ztx3bb8bm_mzw0hknqc0000gn/T/tmp.0jb32zqIvy.fish" }
  if vim.fn.has "mac" == 1 then
    if argc == 1 and string.match(argv[1], "/var/folders/.+/.+/T/tmp%.%w+%.fish$") then
      return true
    end
  end
  if vim.fn.has "linux" == 1 then
    if argc == 1 and string.match(argv[1], "/tmp/tmp%.%w+%.fish$") then
      return true
    end
  end

  -- when nvim is used in vipe (my script)
  if argc == 1 and string.match(argv[1], "/tmp/vipe%.[0-9]+%.txt$") then
    return true
  end

  return false
end

vim.g.minimal_mode = is_minimal_mode()
