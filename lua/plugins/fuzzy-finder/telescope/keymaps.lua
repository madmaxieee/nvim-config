local M = {}

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts vim.keymap.set.Opts?
local function map(mode, lhs, rhs, opts)
  local ff = require "plugins.fuzzy-finder.keymaps"
  ff.map(ff.FuzzyFinder.telescope, mode, lhs, rhs, opts)
end

function M.set_keymaps()
  map( --
    "n",
    "<leader>ff",
    "<cmd> FFFFind <CR>",
    { desc = "Find files" }
  )

  map( --
    "n",
    "<leader>fw",
    function()
      require("plugins.fuzzy-finder.telescope.multi-grep").multi_grep()
    end,
    { desc = "Live grep" }
  )

  map( --
    "v",
    "<leader>fw",
    function()
      require("telescope.builtin").grep_string { path_display = { "shorten" } }
    end,
    { desc = "Grep string" }
  )

  map( --
    "n",
    "<leader>fg",
    "<cmd> Telescope git_status <CR>",
    { desc = "Git status" }
  )

  map( --
    "n",
    "<leader>fa",
    "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
    { desc = "Find all files" }
  )

  map( --
    "n",
    "<leader>fb",
    "<cmd> Telescope buffers <CR>",
    { desc = "Find buffers" }
  )

  map( --
    "n",
    "<leader>fj",
    "<cmd> Telescope jumplist <CR>",
    { desc = "Find jump" }
  )

  map( --
    "n",
    "<leader>fh",
    "<cmd> Telescope help_tags <CR>",
    { desc = "Help page" }
  )

  map( --
    "n",
    "<leader>fz",
    "<cmd> Telescope current_buffer_fuzzy_find <CR>",
    { desc = "Find in current buffer" }
  )

  map( --
    "n",
    "<leader>fr",
    "<cmd> Telescope resume <CR>",
    { desc = "Resume finding" }
  )

  map( --
    "n",
    "<leader>cm",
    "<cmd> Telescope git_commits <CR>",
    { desc = "Git commits" }
  )

  map( --
    "n",
    "<leader>gg",
    "<cmd> Telescope git_files <CR>",
    { desc = "Find git files" }
  )

  map( --
    "n",
    "<leader>fd",
    "<cmd> Telescope diagnostics <CR>",
    { desc = "Find diagnostic" }
  )

  map( --
    "n",
    "<leader>fs",
    "<cmd> Telescope lsp_document_symbols <CR>",
    { desc = "Search document symbols" }
  )

  map( --
    "n",
    "<leader>ws",
    "<cmd> Telescope lsp_dynamic_workspace_symbols <CR>",
    { desc = "Search workspace symbols" }
  )

  map( --
    "n",
    "<leader>fc",
    "<cmd> Telescope command_history <CR>",
    { desc = "Search command history" }
  )

  map( --
    "n",
    "<leader>fu",
    "<cmd> Telescope undo <CR>",
    { desc = "Search undo history" }
  )

  map( --
    "n",
    "<leader>p",
    "<cmd>Telescope neoclip<cr>",
    { desc = "neoclip" }
  )
end

return M
