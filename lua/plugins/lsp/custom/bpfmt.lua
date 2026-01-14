local helpers = require("null-ls.helpers")

return function()
  if not vim.env.ANDROID_BUILD_TOP then
    return nil
  end

  return {
    name = "bpfmt",
    method = require("null-ls").methods.FORMATTING,
    filetypes = { "bp" },
    generator = helpers.formatter_factory({
      command = ("%s/prebuilts/build-tools/linux-x86/bin/bpfmt"):format(
        vim.env.ANDROID_BUILD_TOP
      ),
      args = { "-o" },
      to_stdin = true,
    }),
  }
end
