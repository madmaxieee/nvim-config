local map = require("utils").safe_keymap_set
local float_window_config = require("utils").float_window_config

local lazygit = nil

return {
  "akinsho/toggleterm.nvim",
  keys = {
    "<A-i>",
    {
      "<A-g>",
      mode = "n",
      function()
        if lazygit == nil then
          return
        end
        lazygit:toggle()
      end,
      desc = "Flash",
    },
  },
  version = "*",
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal
    lazygit = Terminal:new {
      cmd = "exec lazygit",
      direction = "float",
      hidden = true,
      float_opts = float_window_config(0.8, 0.8, {}),
      on_open = function(term)
        map("t", "<C-c>", "<cmd>close<CR>", { buffer = term.bufnr })
        map("t", "<A-g>", "<cmd>close<CR>", { buffer = term.bufnr })
      end,
    }

    require("toggleterm").setup {
      open_mapping = "<A-i>",
      direction = "float",
      float_opts = float_window_config(0.8, 0.6, {}),
    }
  end,
}
