---@class AgentmuxContextOpts
---@field buf integer
---@field win integer

---@class ContextRange
---@field from integer[] { line, col } (1,0-based)
---@field to integer[] { line, col } (1,0-based)
---@field kind "char"|"line"|"block"

local M = {}

---@param buf integer
---@return ContextRange|nil
local function get_selection_range(buf)
  local mode = vim.fn.mode()
  local kind = (mode == "V" and "line")
    or (mode == "v" and "char")
    or (mode == "\22" and "block")
  if not kind then
    return nil
  end

  -- Exit visual mode for consistent marks
  if vim.fn.mode():match("[vV\22]") then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<esc>", true, false, true),
      "x",
      true
    )
  end

  local from = vim.api.nvim_buf_get_mark(buf, "<")
  local to = vim.api.nvim_buf_get_mark(buf, ">")
  if from[1] > to[1] or (from[1] == to[1] and from[2] > to[2]) then
    from, to = to, from
  end
  if kind == "block" and from[2] > to[2] then
    from[2], to[2] = to[2], from[2]
  end

  return {
    from = { from[1], from[2] },
    to = { to[1], to[2] },
    kind = kind,
  }
end

---@param range ContextRange
local function format_range(range)
  if range.kind == "char" then
    return string.format(
      "L%dC%d-L%dC%d",
      range.from[1],
      range.from[2],
      range.to[1],
      range.to[2]
    )
  elseif range.kind == "line" then
    return string.format("L%d-L%d", range.from[1], range.to[1])
  elseif range.kind == "block" then
    return string.format(
      "L%dC%d-L%dC%d",
      range.from[1],
      range.from[2],
      range.to[1],
      range.to[2]
    )
  end
end

---@param win integer
local function format_cursor_pos(win)
  local pos = vim.api.nvim_win_get_cursor(win)
  return string.format("L%d", pos[1])
end

---@param buf integer
local function format_buf(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  path = vim.fs.abspath(path)
  path = vim.fs.normalize(path)
  return path
end

---@param diagnostic vim.Diagnostic
local function format_diagnostic(diagnostic)
  return string.format(
    "%s %s (%s): %s",
    format_buf(diagnostic.bufnr),
    format_range({
      from = { diagnostic.lnum + 1, diagnostic.col },
      to = { diagnostic.end_lnum + 1, diagnostic.end_col },
      kind = "char",
    }),
    diagnostic.source or "unknown source",
    diagnostic.message:gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")
  )
end

---@type table<string, fun(opts: AgentmuxContextOpts): string?>
M.contexts = {
  this = function(opts)
    local range = get_selection_range(opts.buf)
    return string.format(
      "%s %s",
      format_buf(opts.buf),
      range and format_range(range) or format_cursor_pos(opts.win)
    )
  end,
  file = function(opts)
    return format_buf(opts.buf)
  end,
  diagnostics = function(opts)
    local diagnostics = vim.diagnostic.get(opts.buf)
    if #diagnostics == 0 then
      return nil
    end
    local formatted = {}
    for _, diag in ipairs(diagnostics) do
      table.insert(formatted, format_diagnostic(diag))
    end
    return table.concat(formatted, "\n")
  end,
}

---@param text string
---@param opts AgentmuxContextOpts
---@return string
function M.transform(text, opts)
  local output, _ = text:gsub("@(%w+)", function(name)
    local fn = M.contexts[name]
    if fn then
      return fn(opts) or ""
    end
    return "@" .. name
  end)
  return output
end

return M
