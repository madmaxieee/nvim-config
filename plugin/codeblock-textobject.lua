-- Markdown fenced code block text objects
-- iC = inside code block
-- aC = around code block, including fences

local map = require("utils").safe_keymap_set

local function is_fence(line)
  return line:match("^%s*```") ~= nil
end

local function find_prev_fence(bufnr, from_lnum)
  local chunk_size = 100

  for chunk_end = from_lnum, 1, -chunk_size do
    local chunk_start = math.max(1, chunk_end - chunk_size + 1)

    -- nvim_buf_get_lines() is 0-indexed, end-exclusive
    local lines =
      vim.api.nvim_buf_get_lines(bufnr, chunk_start - 1, chunk_end, false)

    for i = #lines, 1, -1 do
      if is_fence(lines[i]) then
        return chunk_start + i - 1
      end
    end
  end
end

local function find_next_fence(bufnr, from_lnum)
  local chunk_size = 100
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  for chunk_start = from_lnum, line_count, chunk_size do
    local chunk_end = math.min(line_count, chunk_start + chunk_size - 1)

    -- nvim_buf_get_lines() is 0-indexed, end-exclusive
    local lines =
      vim.api.nvim_buf_get_lines(bufnr, chunk_start - 1, chunk_end, false)

    for i, line in ipairs(lines) do
      if is_fence(line) then
        return chunk_start + i - 1
      end
    end
  end
end

local function select_code_block(inner)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1]

  local start = find_prev_fence(bufnr, lnum)
  if not start then
    return
  end

  local finish = find_next_fence(bufnr, start + 1)
  if not finish then
    return
  end

  local lnum_start = inner and (start + 1) or start
  local lnum_end = inner and (finish - 1) or finish

  if lnum_start > lnum_end then
    return
  end

  vim.cmd("normal! " .. lnum_start .. "GV" .. lnum_end .. "G")
end

map("o", "iC", function()
  select_code_block(true)
end, { desc = "Select commented lines" })

map("x", "iC", function()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<esc>", true, true, true),
    "nx",
    false
  )
  select_code_block(true)
end, { desc = "Select commented lines" })

map("o", "aC", function()
  select_code_block(false)
end, { desc = "Select commented lines" })

map("x", "aC", function()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<esc>", true, true, true),
    "nx",
    false
  )
  select_code_block(false)
end, { desc = "Select commented lines" })
