local map = require("utils").safe_keymap_set

return {
  "akinsho/toggleterm.nvim",
  keys = {
    "<A-i>",
    "<leader>lg",
  },
  version = "*",
  opts = {
    open_mapping = "<A-i>",
    direction = "float",
    float_opts = {
      border = "rounded",
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new { cmd = "lazygit", hidden = true }

    map("n", "<leader>lg", function()
      lazygit:toggle()
    end, { desc = "Toggle terminal" })
  end,
}
