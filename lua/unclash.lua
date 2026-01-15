-- unclash.nvim wip plugin for conflict highlighting

local M = {}

---@class State
---@field conflicted_files table<string, boolean> map of conflicted file paths
---@field conflicted_bufs table<integer, boolean> map of conflicted buffer numbers
---@field hunks table<integer, ConflictHunk[]>

---@type State
local state = {
  conflicted_files = {},
  conflicted_bufs = {},
  hunks = {},
}

local ns = vim.api.nvim_create_namespace("ConflictMarkers")

local TARGET_MARKER = "<<<<<<<"
local BASE_MARKER = "|||||||"
local SEPARATOR_MARKER = "======="
local SOURCE_MARKER = ">>>>>>>"

---@alias MarkerType "target" | "base" | "separator" | "source"

---@class Marker
---@field line integer
---@field type MarkerType

---@class MarkerSet
---@field target Marker[]
---@field base Marker[]
---@field separator Marker[]
---@field source Marker[]

---@param path string a directory or a single file
---@return table<string, boolean> conflicted files
local function detect_conflicted_files(path)
  local jobs = {
    vim.system({ "rg", "-l", "^<{7}", path }),
    vim.system({ "rg", "-l", "^={7}", path }),
    vim.system({ "rg", "-l", "^>{7}", path }),
  }

  local job_results = {}
  for i, job in ipairs(jobs) do
    job_results[i] = job:wait()
  end

  for _, result in pairs(job_results) do
    -- code 0 indicates a match was found
    if result.code ~= 0 then
      return {}
    end
  end

  local candidate_files = {}
  for _, result in ipairs(job_results) do
    for line in vim.gsplit(result.stdout, "\n") do
      if line ~= "" then
        candidate_files[line] = (candidate_files[line] or 0) + 1
      end
    end
  end

  local conflicted_files = {}
  for file, count in pairs(candidate_files) do
    if count == #jobs then
      conflicted_files[file] = true
    end
  end

  return conflicted_files
end

local augroup =
  vim.api.nvim_create_augroup("ConflictDetection", { clear = true })

vim.api.nvim_create_autocmd(
  { "VimEnter", "FileChangedShellPost", "DirChanged" },
  {
    group = augroup,
    desc = "Detect conflicted files in the current working directory on startup",
    callback = function()
      state.conflicted_files = detect_conflicted_files(vim.fn.getcwd())
    end,
  }
)

vim.api.nvim_create_autocmd("BufReadPre", {
  group = augroup,
  desc = "Detect if the opened file is conflicted",
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local conflicted_files = detect_conflicted_files(file)
    state.conflicted_files[file] = conflicted_files[file] or nil
    state.conflicted_bufs[args.buf] = conflicted_files[file] or nil
  end,
})

---@param bufnr integer
---@return MarkerSet
local function find_markers(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  ---@type MarkerSet
  local markers = {
    target = {},
    separator = {},
    base = {},
    source = {},
  }
  for i, line in ipairs(lines) do
    if vim.startswith(line, TARGET_MARKER) then
      markers.target[#markers.target + 1] = {
        line = i,
        type = "target",
      }
    elseif vim.startswith(line, BASE_MARKER) then
      markers.base[#markers.base + 1] = {
        line = i,
        type = "base",
      }
    elseif vim.startswith(line, SEPARATOR_MARKER) then
      markers.separator[#markers.separator + 1] = {
        line = i,
        type = "separator",
      }
    elseif vim.startswith(line, SOURCE_MARKER) then
      markers.source[#markers.source + 1] = {
        line = i,
        type = "source",
      }
    end
  end

  return markers
end

---@param markers MarkerSet
---@param line integer
---@return Marker?
-- Finds the next marker after the given line, also removes all markers before
-- it from the marker set
local function get_next_marker(markers, line)
  ---@type Marker?
  local next_marker = nil
  for _, t in ipairs({ "target", "base", "separator", "source" }) do
    if #markers[t] > 0 then
      while #markers[t] > 0 and markers[t][1].line <= line do
        table.remove(markers[t], 1)
      end
      if #markers[t] > 0 then
        if not next_marker or markers[t][1].line < next_marker.line then
          next_marker = markers[t][1]
        end
      end
    end
  end
  return next_marker
end

---@class HighlightRange
---@field start_line integer 1-based indexing, inclusive
---@field end_line integer
---@field hl_group string

---@param bufnr integer
---@param range HighlightRange
local function hl(bufnr, range)
  vim.api.nvim_buf_set_extmark(bufnr, ns, range.start_line - 1, 0, {
    end_line = range.end_line,
    hl_group = range.hl_group,
    hl_eol = true,
  })
end

local ACCEPT_CURRENT = "[Accept Current]"
local ACCEPT_INCOMING = "[Accept Incoming]"
local ACCEPT_BOTH = "[Accept Both]"
local ACCEPT_NONE = "[Accept None]"

local _cursor = 0
local accept_current_range = {
  lower = _cursor,
  upper = _cursor + #ACCEPT_CURRENT - 1,
}
_cursor = _cursor + #ACCEPT_CURRENT + 1
local accept_incoming_range = {
  lower = _cursor,
  upper = _cursor + #ACCEPT_INCOMING - 1,
}
_cursor = _cursor + #ACCEPT_INCOMING + 1
local accept_both_range = {
  lower = _cursor,
  upper = _cursor + #ACCEPT_BOTH - 1,
}
_cursor = _cursor + #ACCEPT_BOTH + 1
local accept_none_range = {
  lower = _cursor,
  upper = _cursor + #ACCEPT_NONE - 1,
}

---@param bufnr integer
---@param line integer
local function draw_virtual_line(bufnr, line)
  vim.api.nvim_buf_set_extmark(bufnr, ns, line - 1, 0, {
    virt_lines = {
      {
        { ACCEPT_CURRENT, "Normal" },
        { " ", "" },
        { ACCEPT_INCOMING, "Normal" },
        { " ", "" },
        { ACCEPT_BOTH, "Normal" },
        { " ", "" },
        { ACCEPT_NONE, "Normal" },
      },
    },
    virt_lines_above = true,
  })
end

---@class ConflictHunk
---@field target Marker
---@field base Marker?
---@field separator Marker
---@field source Marker

---@param bufnr integer
---@param conflicts ConflictHunk[]
local function highlight_conflicts(bufnr, conflicts)
  -- clear previous extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for _, conflict in ipairs(conflicts) do
    draw_virtual_line(bufnr, conflict.target.line)
    if conflict.base then
      hl(bufnr, {
        start_line = conflict.target.line,
        end_line = conflict.base.line - 1,
        hl_group = "DiffAdd",
      })
      hl(bufnr, {
        start_line = conflict.base.line,
        end_line = conflict.separator.line - 1,
        hl_group = "DiffText",
      })
    else
      hl(bufnr, {
        start_line = conflict.target.line,
        end_line = conflict.separator.line - 1,
        hl_group = "DiffAdd",
      })
    end
    hl(bufnr, {
      start_line = conflict.separator.line + 1,
      end_line = conflict.source.line,
      hl_group = "DiffDelete",
    })
  end
end

vim.api.nvim_create_autocmd({ "BufRead", "TextChanged" }, {
  group = augroup,
  desc = "Apply highlighting to conflicted files",
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)

    if not state.conflicted_files[file] then
      return
    end

    local markers = find_markers(args.buf)

    ---@type ConflictHunk[]
    local hunks = {}

    ---@type Marker?
    local target = nil

    while true do
      local base = nil
      ---@type Marker?
      local separator = nil
      ---@type Marker?
      local source = nil

      while not (target and target.type == "target") do
        target = get_next_marker(markers, target and target.line or 0)
        if not target then
          break
        end
      end
      if not target then
        break
      end

      ---@type Marker?
      local next_marker = get_next_marker(markers, target.line)
      if not next_marker then
        break
      end

      if next_marker.type == "target" then
        target = next_marker
        goto continue
      elseif next_marker.type == "base" then
        base = next_marker
      elseif next_marker.type == "separator" then
        separator = next_marker
      elseif next_marker.type == "source" then
        target = nil
        goto continue
      end

      if base then
        next_marker = get_next_marker(markers, next_marker.line)
        if not next_marker then
          break
        end
        if next_marker.type == "target" then
          target = next_marker
          goto continue
        elseif next_marker.type == "separator" then
          separator = next_marker
        else
          target = nil
          goto continue
        end
      end

      assert(separator)
      assert(next_marker)

      ---@diagnostic disable-next-line: need-check-nil
      next_marker = get_next_marker(markers, next_marker.line)
      if not next_marker then
        break
      end

      if next_marker.type == "target" then
        target = next_marker
        goto continue
      elseif next_marker.type == "source" then
        source = next_marker
      else
        target = nil
        goto continue
      end

      assert(target)
      assert(source)

      hunks[#hunks + 1] = {
        target = target,
        base = base,
        separator = separator,
        source = source,
      }

      target = nil
      ::continue::
    end

    state.hunks[args.buf] = hunks
    highlight_conflicts(args.buf, hunks)
  end,
})

---@param opts? {wrap?: boolean, bottom?: boolean}
function M.next_conflict(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local hunks = state.hunks[bufnr]
  if not hunks or #hunks == 0 then
    vim.notify("No conflicts detected in this file", vim.log.levels.INFO)
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local marker_type = opts.bottom and "source" or "target"
  for _, hunk in ipairs(hunks) do
    if hunk[marker_type].line > cursor[1] then
      vim.api.nvim_win_set_cursor(0, { hunk[marker_type].line, 0 })
      return
    end
  end
  -- wrap around to the first hunk
  if opts.wrap then
    if hunks and #hunks > 0 then
      vim.api.nvim_win_set_cursor(0, { hunks[1].target.line, 0 })
    end
  end
end

---@param opts? {wrap?: boolean, bottom?: boolean}
function M.prev_conflict(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local hunks = state.hunks[bufnr]
  if not hunks or #hunks == 0 then
    vim.notify("No conflicts detected in this file", vim.log.levels.INFO)
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local marker_type = opts.bottom and "source" or "target"
  for i = #hunks, 1, -1 do
    local hunk = hunks[i]
    if hunk[marker_type].line < cursor[1] then
      vim.api.nvim_win_set_cursor(0, { hunk[marker_type].line, 0 })
      return
    end
  end
  -- wrap around to the last hunk
  if opts.wrap then
    if hunks and #hunks > 0 then
      vim.api.nvim_win_set_cursor(0, { hunks[#hunks].target.line, 0 })
    end
  end
end

vim.keymap.set("n", "]x", function()
  M.next_conflict({ wrap = true })
end, { desc = "Go to next conflict" })

vim.keymap.set("n", "[x", function()
  M.prev_conflict({ wrap = true })
end, { desc = "Go to previous conflict" })

vim.keymap.set("n", "]X", function()
  M.next_conflict({ wrap = true, bottom = true })
end, { desc = "Go to next conflict (bottom marker)" })

vim.keymap.set("n", "[X", function()
  M.prev_conflict({ wrap = true, bottom = true })
end, { desc = "Go to previous conflict (bottom marker)" })

-- run callbacks on virtual line clicks
vim.keymap.set("n", "<LeftMouse>", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if not state.conflicted_bufs[bufnr] then
    return "<LeftMouse>"
  end

  local mouse_pos = vim.fn.getmousepos()
  local screen_pos = vim.fn.screenpos(0, mouse_pos.line, 0)

  -- clicked real line
  if mouse_pos.screenrow == screen_pos.row then
    return "<LeftMouse>"
  end

  local hunks = state.hunks[bufnr]
  if not hunks or #hunks == 0 then
    return "<LeftMouse>"
  end

  for _, hunk in ipairs(hunks) do
    if mouse_pos.line == hunk.target.line then
      -- calculate the real "buffer column" of the mouse click
      -- can't use mouse_pos.col because it only works on actual lines
      local col = mouse_pos.screencol - screen_pos.col
      if
        col >= accept_current_range.lower
        and col <= accept_current_range.upper
      then
        vim.notify("Accept Current", vim.log.levels.INFO)
      elseif
        col >= accept_incoming_range.lower
        and col <= accept_incoming_range.upper
      then
        vim.notify("Accept Incoming", vim.log.levels.INFO)
      elseif
        col >= accept_both_range.lower and col <= accept_both_range.upper
      then
        vim.notify("Accept Both", vim.log.levels.INFO)
      elseif
        col >= accept_none_range.lower and col <= accept_none_range.upper
      then
        vim.notify("Accept None", vim.log.levels.INFO)
      end
      return ""
    end
  end

  return "<LeftMouse>"
end, { expr = true })

return M

-- TODO: make the marker line stand out more
-- TODO: implement accept actions
-- TODO: add snakcs picker to find conflict location
-- TODO: use LSP to provide code actions for resolving conflicts
-- TODO: implement vscode-like merge editor

--[[
<<<<<<< TARGET BRANCH
base content
target content
base content
=======
source content
>>>>>>> SOURCE BRANCH
]]

--[[
<<<<<<< TARGET BRANCH
base content

target content
s
=======
base content
source content
>>>>>>> SOURCE BRANCH
]]

-- for testing
--[[
<<<<<<< TARGET BRANCH
base content
target content
||||||| BASE
base content
=======
base content
source content
>>>>>>> SOURCE BRANCH
]]

-- for testing
--[[
<<<<<<< TARGET BRANCH
base content
target content
||||||| BASE
base content
=======
base content
source content
>>>>>>> SOURCE BRANCH
]]
