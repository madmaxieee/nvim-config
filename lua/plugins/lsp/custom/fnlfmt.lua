local helpers = require("null-ls.helpers")

return function()
  if vim.fn.executable("fnlfmt") ~= 1 then
    return nil
  end

  return {
    name = "fnlfmt",
    method = require("null-ls").methods.FORMATTING,
    filetypes = { "fennel" },
    generator = helpers.formatter_factory({
      command = "fnlfmt",
      args = { "-" },
      to_stdin = true,
    }),
  }
end
