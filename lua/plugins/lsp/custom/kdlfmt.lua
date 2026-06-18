local helpers = require("null-ls.helpers")

return function()
  if vim.fn.executable("kdlfmt") ~= 1 then
    return nil
  end

  return {
    name = "kdlfmt",
    method = require("null-ls").methods.FORMATTING,
    filetypes = { "kdl" },
    generator = helpers.formatter_factory({
      command = "kdlfmt",
      args = { "format", "-" },
      to_stdin = true,
    }),
  }
end
