local config = require "plugins.lsp.config"
if config.cond() then
  config.setup()
end

return {
  require "plugins.lsp.mason",
  require "plugins.lsp.null-ls",
  require "plugins.lsp.nvim-lspconfig",
}
