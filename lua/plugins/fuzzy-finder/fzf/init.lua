return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function()
    vim.cmd.cabbrev("F", "FzfLua")
    require("plugins.fuzzy-finder.fzf.keymaps").set_keymaps()
  end,
  config = function()
    local actions = require("fzf-lua").actions
    require("fzf-lua").setup {
      grep = {
        actions = {
          ["ctrl-f"] = { actions.grep_lgrep },
          ["ctrl-g"] = false,
        },
      },
      live_grep = {
        actions = {
          ["ctrl-f"] = { actions.grep_lgrep },
          ["ctrl-g"] = false,
        },
      },
      files = {
        actions = {
          ["ctrl-f"] = { actions.toggle_ignore },
          ["ctrl-g"] = false,
        },
      },
    }
  end,
}
