local map = require("utils").safe_keymap_set
local float_window_config = require("utils").float_window_config

return {
  "akinsho/toggleterm.nvim",
  event = "VeryLazy",
  keys = { "<A-i>" },
  version = "*",
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new {
      cmd = "exec lazygit",
      direction = "float",
      hidden = true,
      float_opts = float_window_config(0.8, 0.9, {}),
      on_open = function(term)
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
    }

    map("n", "<leader>lg", function()
      lazygit:toggle()
    end, { desc = "Toggle LazyGit" })

    require("toggleterm").setup {
      open_mapping = "<A-i>",
      direction = "float",
      float_opts = float_window_config(0.7, 0.6, {}),
    }
  end,
}
