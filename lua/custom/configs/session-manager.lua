local config = require "session_manager.config"

local home = vim.fn.expand "~"
require("session_manager").setup {
  autoload_mode = config.AutoloadMode.CurrentDir, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
  autosave_ignore_dirs = {
    home,
    home .. "/Downloads",
    "/tmp",
  },
}

local augroup = vim.api.nvim_create_augroup("session_manager", { clear = true })

vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "SessionLoadPost",
  group = augroup,
  callback = function()
    require("nvim-tree.api").tree.toggle(false, true)
  end,
})
