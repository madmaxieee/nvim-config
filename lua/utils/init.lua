local M = {}

---Wrapper around vim.keymap.set that will
---not create a keymap if a lazy key handler exists.
---It will also set `silent` to true by default.
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts vim.keymap.set.Opts?
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler

  local modes = type(mode) == "string" and { mode } or mode
  ---@cast modes string[]

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  local Config = require "lazy.core.config"
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

-- @param height_ratio number (0.0 - 1.0)
-- @param width_ratio number (0.0 - 1.0)
-- @param opts table
function M.float_window_config(height_ratio, width_ratio, opts)
  local screen_w = vim.opt.columns:get()
  local screen_h = vim.opt.lines:get()
  local window_w = screen_w * width_ratio
  local window_h = screen_h * height_ratio
  local window_w_int = math.ceil(window_w)
  local window_h_int = math.ceil(window_h)
  local center_x = (screen_w - window_w) / 2
  local center_y = (vim.opt.lines:get() - window_h) / 2
  return {
    border = opts.border or "rounded",
    relative = opts.relative or "editor",
    winblend = opts.winblend or 0,
    row = center_y,
    col = center_x,
    width = window_w_int,
    height = window_h_int,
  }
end

---@param list any[]
---@param x any
---@return boolean
function M.in_list(list, x)
  for _, v in ipairs(list) do
    if v == x then
      return true
    end
  end
  return false
end

---remove an item from a list by value
---@param list any[]
---@param value_to_remove any
function M.remove_by_value(list, value_to_remove)
  for i = #list, 1, -1 do -- Iterate backwards!
    if list[i] == value_to_remove then
      table.remove(list, i)
    end
  end
end

---filters a list
---@param list any[]
---@param condition fun(item: any): boolean
---@return any[]
function M.filter_list(list, condition)
  local new_list = {}
  for _, v in ipairs(list) do
    if condition(v) then
      table.insert(new_list, v)
    end
  end
  return new_list
end

---@alias KeymapSpec [string,function,vim.keymap.set.Opts?]
---@class RepeatablePairSpec
---@field next KeymapSpec
---@field prev KeymapSpec
---
---@param modes string|string[]
---@param specs RepeatablePairSpec
function M.map_repeatable_pair(modes, specs)
  local map = M.safe_keymap_set
  local next_repeat, prev_repeat = M.make_repeatable_move_pair { next = specs.next[2], prev = specs.prev[2] }
  map(modes, specs.next[1], next_repeat, specs.next[3])
  map(modes, specs.prev[1], prev_repeat, specs.prev[3])
end

---@class Moves
---@field next function
---@field prev function
---@param moves Moves
---@return function
---@return function
function M.make_repeatable_move_pair(moves)
  local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
  local next_repeat, prev_repeat = ts_repeat_move.make_repeatable_move_pair(moves.next, moves.prev)
  return next_repeat, prev_repeat
end

return M
