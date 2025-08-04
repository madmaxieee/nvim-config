local helpers = require "null-ls.helpers"

local generator
if vim.env.ANDROID_BUILD_TOP then
  generator = helpers.formatter_factory {
    command = ("%s/prebuilts/build-tools/linux-x86/bin/bpfmt"):format(vim.env.ANDROID_BUILD_TOP),
    args = { "-o" },
    to_stdin = true,
  }
else
  -- noop if ANDROID_BUILD_TOP is not in env
  generator = helpers.formatter_factory {
    command = "cat",
    to_stdin = true,
  }
end

return {
  name = "bpfmt",
  method = require("null-ls").methods.FORMATTING,
  filetypes = { "bp" },
  generator = generator,
}
