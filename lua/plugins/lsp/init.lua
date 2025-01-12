local config = require "plugins.lsp.config"
if config.cond() then
  config.init()
end

return {
  require "plugins.lsp.null-ls",
  require "plugins.lsp.nvim-lspconfig",
}
