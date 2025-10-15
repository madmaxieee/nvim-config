local helpers = require "null-ls.helpers"

return function()
  if vim.fn.executable "pyformat" ~= 1 then
    return nil
  end

  if require("modes").google3_mode then
    return {
      name = "pyformat",
      method = require("null-ls").methods.FORMATTING,
      filetypes = { "python" },
      generator = helpers.formatter_factory {
        command = "pyformat",
        args = {},
        to_stdin = true,
      },
    }
  end
end
