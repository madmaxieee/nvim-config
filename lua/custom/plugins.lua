local plugins = {
  {
    "ggandor/leap.nvim",
    -- leap.nvim lazy loads itself
    lazy = false,
    config = function ()
      require('leap').add_default_mappings(true)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
}
return plugins
