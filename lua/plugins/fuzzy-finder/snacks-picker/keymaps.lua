local M = {}

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts vim.keymap.set.Opts?
local function map(mode, lhs, rhs, opts)
  local ff = require "plugins.fuzzy-finder.keymaps"
  ff.map(ff.FuzzyFinder.snacks_picker, mode, lhs, rhs, opts)
end

function M.set_keymaps()
  map( --
    "n",
    "<leader>ff",
    function()
      require("plugins.fuzzy-finder.snacks-picker.fff").fff()
    end,
    { desc = "FFF" }
  )

  map( --
    "n",
    "<leader>fw",
    function()
      require("plugins.fuzzy-finder.snacks-picker.multi-grep").multi_grep()
    end,
    { desc = "Live grep" }
  )

  map( --
    "v",
    "<leader>fw",
    function()
      require("snacks").picker.grep_word()
    end,
    { desc = "Grep string" }
  )

  map( --
    "n",
    "<leader>fg",
    require("snacks").picker.git_status,
    { desc = "Git status" }
  )

  map( --
    "n",
    "<leader>fa",
    function()
      require("snacks").picker.files {
        cmd = "fd",
        args = {
          "--color=never",
          "--hidden",
          "--type",
          "f",
          "--type",
          "l",
          "--no-ignore",
          "--exclude",
          ".git",
        },
      }
    end,
    { desc = "Find all files" }
  )

  map( --
    "n",
    "<leader>fb",
    function()
      require("snacks").picker.buffers()
    end,
    { desc = "Find buffers" }
  )

  map( --
    "n",
    "<leader>fj",
    function()
      require("snacks").picker.jumps()
    end,
    { desc = "Find jump" }
  )

  map( --
    "n",
    "<leader>fh",
    function()
      require("snacks").picker.help()
    end,
    { desc = "Find help tags" }
  )

  map( --
    "n",
    "<leader>fz",
    function()
      require("snacks").picker.lines { layout = "default" }
    end,
    { desc = "Find in current buffer" }
  )

  map( --
    "n",
    "<leader>fr",
    function()
      require("snacks").picker.resume()
    end,
    { desc = "Resume finding" }
  )

  map( --
    "n",
    "<leader>cm",
    function()
      require("snacks").picker.git_log()
    end,
    { desc = "Git commits" }
  )

  map( --
    "n",
    "<leader>gg",
    function()
      require("snacks").picker.git_files()
    end,
    { desc = "Find git files" }
  )

  map( --
    "n",
    "<leader>fd",
    function()
      require("snacks").picker.diagnostics()
    end,
    { desc = "Find diagnostics" }
  )

  map( --
    "n",
    "<leader>fs",
    function()
      require("snacks").picker.lsp_symbols()
    end,
    { desc = "Search document symbols" }
  )

  map( --
    "n",
    "<leader>ws",
    function()
      require("snacks").picker.lsp_workspace_symbols()
    end,
    { desc = "Search workspace symbols" }
  )

  map( --
    "n",
    "<leader>fc",
    function()
      require("snacks").picker.command_history()
    end,
    { desc = "Search command history" }
  )

  map( --
    "n",
    "<leader>fu",
    function()
      require("snacks").picker.undo()
    end,
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
