if vim.fn.isdirectory "/google/bin" ~= 1 then
  return {}
end

local utils = require "utils"

utils.on_load("nvim-lspconfig", function()
  require "plugins.google.ciderlsp"
end)

return {
  {
    import = "plugins.google",
  },
}
