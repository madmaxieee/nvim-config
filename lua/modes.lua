---@class Modes
---@field minimal_mode? boolean
---@field difftool_mode? boolean
---@field google3_mode? boolean

---@type Modes
local M = {}

local cwd = vim.uv.cwd() or vim.fn.getcwd()

local function is_minimal_mode()
  -- allow override with `nvim --cmd 'lua vim.g.minimal_mode=true'`
  if vim.g.minimal_mode then
    return true
  end

  -- when nvim used by tmux scrollback buffer
  if vim.env.TMUX_SCROLLBACK then
    return true
  end

  -- when nvim used by git to edit commit messages
  if vim.env.GIT_EXEC_PATH then
    return true
  end

  -- when nvim used by opencode to edit prompt
  if vim.env.OPENCODE then
    return true
  end

  local argc = vim.fn.argc()
  local argv = vim.fn.argv()
  -- if on macos then argv will be like this:
  -- { "/var/folders/pg/4v3k1ztx3bb8bm_mzw0hknqc0000gn/T/tmp.UDKOra60Bm.fish" }
  -- { "/private/var/folders/pg/4v3k1ztx3bb8bm_mzw0hknqc0000gn/T/editor-Hj11cQ.jjdescription" }
  -- { "/private/var/folders/pg/4v3k1ztx3bb8bm_mzw0hknqc0000gn/T/tmp.0jb32zqIvy.fish" }
  if argc == 1 then
    if
      vim.fn.has("mac") == 1
        and string.match(argv[1], "/var/folders/[^/]+/[^/]+/T/")
      or vim.fn.has("linux") == 1 and string.match(argv[1], "^/tmp/")
    then
      -- when used by fish shell to edit command line
      if string.match(argv[1], "/tmp%.%w+%.fish$") then
        return true
      end
      -- when used by jujitsu to edit description
      if string.match(argv[1], "/editor%-%w+%.jjdescription$") then
        return true
      end
    end
  end

  -- when nvim is used in vipe (my script)
  if argc == 1 and string.match(argv[1], "^/tmp/vipe%.[0-9]+%.txt$") then
    return true
  end

  return false
end

local function is_difftool_mode()
  for _, arg in ipairs(vim.v.argv) do
    if arg:match([[^%+DiffviewOpen]]) then
      return true
    end
  end
  return false
end

local function is_google3_mode()
  return vim.startswith(cwd, "/google/src/cloud")
end

return setmetatable(M, {
  __index = function(t, k)
    local get_mode = {
      minimal_mode = is_minimal_mode,
      difftool_mode = is_difftool_mode,
      google3_mode = is_google3_mode,
    }
    local mode = get_mode[k]()
    rawset(t, k, mode)
    return mode
  end,
})
