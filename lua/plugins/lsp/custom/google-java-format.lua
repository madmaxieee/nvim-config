local helpers = require("null-ls.helpers")
local null_ls = require("null-ls")

return function()
  if not vim.env.ANDROID_BUILD_TOP then
    return nil
  end

  return {
    name = "google-java-format",
    method = null_ls.methods.FORMATTING,
    filetypes = { "java" },
    generator = helpers.formatter_factory({
      command = "google-java-format",
      args = { "--aosp", "-" },
      to_stdin = true,
    }),
  }
end
