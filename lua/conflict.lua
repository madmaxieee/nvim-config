-- wip plugin for conflict highlighting

---@type {conflicted_files: table<string, boolean>}
local state = {
  conflicted_files = {},
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

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  desc = "Detect conflicted files in the current working directory on startup",
  callback = function()
    state.conflicted_files = detect_conflicted_files(vim.fn.getcwd())
  end,
})

vim.api.nvim_create_autocmd("BufRead", {
  group = augroup,
  desc = "Detect if the opened file is conflicted",
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local conflicted_files = detect_conflicted_files(file)
    state.conflicted_files[file] = conflicted_files[file] or nil
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
  vim.print(next_marker)
  return next_marker
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

      -- move all extmark logics here
      if base then
        vim.api.nvim_buf_set_extmark(args.buf, ns, target.line - 1, 0, {
          end_line = base.line - 1,
          hl_group = "DiffAdd",
          hl_eol = true,
        })
        vim.api.nvim_buf_set_extmark(args.buf, ns, base.line - 1, 0, {
          end_line = separator.line - 1,
          hl_group = "DiffText",
          hl_eol = true,
        })
      else
        vim.api.nvim_buf_set_extmark(args.buf, ns, target.line - 1, 0, {
          end_line = separator.line - 1,
          hl_group = "DiffAdd",
          hl_eol = true,
        })
      end

      vim.api.nvim_buf_set_extmark(args.buf, ns, separator.line, 0, {
        end_line = source.line,
        hl_group = "DiffDelete",
        hl_eol = true,
      })

      target = nil
      ::continue::
    end
  end,
})

-- TODO: make the marker line stand out more
-- TODO: reuse extmarks
-- TODO: add commands to navigate between conflict markers
-- TODO: add snakcs picker to find conflict location
-- TODO: use LSP to provide code actions for resolving conflicts

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
