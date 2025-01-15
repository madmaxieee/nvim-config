local M = {}

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts vim.keymap.set.Opts?
local function map(mode, lhs, rhs, opts)
  local ff = require "plugins.fuzzy-finder.keymaps"
  ff.map(ff.FuzzyFinder.fzf, mode, lhs, rhs, opts)
end

function M.set_keymaps()
  -- builtin
  map( --
    "n",
    "<leader>ff",
    "<cmd> FzfLua files <CR>",
    { desc = "Find files" }
  )

  map( --
    "n",
    "<leader>fw",
    "<cmd> FzfLua live_grep <CR>",
    { desc = "Live grep" }
  )

  map( --
    "v",
    "<leader>fw",
    "<cmd> FzfLua grep_visual <CR>",
    { desc = "Grep string" }
  )

  map( --
    "n",
    "<leader>fg",
    "<cmd> FzfLua git_status <CR>",
    { desc = "Git status" }
  )

  map( --
    "n",
    "<leader>fa",
    "<cmd> FzfLua files fd_opts=--no-ignore <CR>",
    { desc = "Find all files" }
  )

  map( --
    "n",
    "<leader>fb",
    "<cmd> FzfLua buffers <CR>",
    { desc = "Find buffers" }
  )

  map( --
    "n",
    "<leader>fj",
    "<cmd> FzfLua jumps <CR>",
    { desc = "Find jump" }
  )

  map( --
    "n",
    "<leader>fh",
    "<cmd> FzfLua helptags <CR>",
    { desc = "Find help tags" }
  )

  map( --
    "n",
    "<leader>fz",
    "<cmd> FzfLua grep_curbuf <CR>",
    { desc = "Find in current buffer" }
  )

  map( --
    "n",
    "<leader>fr",
    "<cmd> FzfLua resume <CR>",
    { desc = "Resume finding" }
  )

  map( --
    "n",
    "<leader>cm",
    "<cmd> FzfLua git_commits <CR>",
    { desc = "Git commits" }
  )

  map( --
    "n",
    "<leader>gg",
    "<cmd> FzfLua git_files <CR>",
    { desc = "Find git files" }
  )

  map( --
    "n",
    "<leader>fd",
    "<cmd> FzfLua diagnostics_workspace <CR>",
    { desc = "Find diagnostics" }
  )

  map( --
    "n",
    "<leader>fs",
    "<cmd> FzfLua lsp_document_symbols <CR>",
    { desc = "Search document symbols" }
  )

  map( --
    "n",
    "<leader>ws",
    "<cmd> FzfLua lsp_live_workspace_symbols <CR>",
    { desc = "Search workspace symbols" }
  )
end

return M
