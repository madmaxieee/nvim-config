local config = require "plugins.lsp.config"
if config.cond() then
  config.setup()
end

return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },

  require "plugins.lsp.null-ls",
  require "plugins.lsp.nvim-lspconfig",
}
