local M = {}

---@enum FuzzyFinder
M.FuzzyFinder = {
  telescope = "telescope",
  fzf = "fzf",
}

if not vim.g.FuzzyFinder or not M.FuzzyFinder[vim.g.FuzzyFinder] then
  vim.g.FuzzyFinder = M.FuzzyFinder.telescope
end

---@class FuzzyFinderKeymapSpec
---@field mode string[]
---@field lhs string
---@field rhs string|function
---@field opts vim.keymap.set.Opts?

---@alias FuzzyFinderKeymaps table<FuzzyFinder, table<string, FuzzyFinderKeymapSpec>>
---@type FuzzyFinderKeymaps
local keymaps_table = {
  [M.FuzzyFinder.telescope] = {},
  [M.FuzzyFinder.fzf] = {},
}
M.keymaps_table = keymaps_table

---@param mode string|string[]
---@param lhs string
local function make_key(mode, lhs)
  if type(mode) == "table" then
    mode = table.concat(mode, "")
  end
  return mode .. ":" .. lhs
end

---@param namespace FuzzyFinder
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts vim.keymap.set.Opts?
function M.map(namespace, mode, lhs, rhs, opts)
  mode = type(mode) == "table" and mode or { mode }

  keymaps_table[namespace][make_key(mode, lhs)] = {
    mode = mode,
    lhs = lhs,
    rhs = rhs,
    opts = opts,
  }

  if namespace == vim.g.FuzzyFinder then
    for _, m in ipairs(mode) do
      vim.keymap.set(m, lhs, rhs, opts)
    end
  end
end

function M.set_active_keymaps()
  local keymaps = keymaps_table[vim.g.FuzzyFinder]
  for _, keymap in pairs(keymaps) do
    for _, m in ipairs(keymap.mode) do
      vim.keymap.set(m, keymap.lhs, keymap.rhs, keymap.opts)
    end
  end
end

---@param fuzzy_finder FuzzyFinder
function M.set_fuzzy_finder(fuzzy_finder)
  vim.g.FuzzyFinder = fuzzy_finder
  M.set_active_keymaps()
end

function M.setup()
  vim.api.nvim_create_autocmd("SessionLoadPost", {
    group = vim.api.nvim_create_augroup("FuzzyFinder", { clear = true }),
    desc = "set active fuzzy finder keymaps after session load",
    callback = function()
      M.set_active_keymaps()
    end,
  })

  vim.api.nvim_create_user_command("FuzzyFinderToggle", function()
    local new_fuzzy_finder
    if vim.g.FuzzyFinder == M.FuzzyFinder.telescope then
      new_fuzzy_finder = M.FuzzyFinder.fzf
    else
      new_fuzzy_finder = M.FuzzyFinder.telescope
    end
    M.set_fuzzy_finder(new_fuzzy_finder)
    vim.notify("Fuzzy finder set to " .. new_fuzzy_finder)
  end, {})

  vim.api.nvim_create_user_command("FuzzyFinderSetTelescope", function()
    M.set_fuzzy_finder(M.FuzzyFinder.telescope)
  end, {})

  vim.api.nvim_create_user_command("FuzzyFinderSetFzf", function()
    M.set_fuzzy_finder(M.FuzzyFinder.fzf)
  end, {})
end

return M
