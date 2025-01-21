local helpers = require "null-ls.helpers"
local severities = helpers.diagnostics.severities

local diagnostics = helpers.diagnostics.from_pattern(
  "[^:]+:(%d+):  (.+)  %[(.+)%/(.+)%] %[%d+%]",
  { "row", "message", "severity", "label" },
  {
    severities = {
      build = severities.warning,
      whitespace = severities.hint,
      runtime = severities.warning,
      legal = severities.information,
      readability = severities.information,
    },
  }
)

return {
  method = require("null-ls").methods.DIAGNOSTICS,
  filetypes = { "cpp", "c" },
  generator = helpers.generator_factory {
    command = "cpplint",
    args = {
      "$FILENAME",
    },
    format = "line",
    to_stdin = false,
    from_stderr = true,
    to_temp_file = true,
    on_output = function(line, params)
      local diag = diagnostics(line, params)
      if not diag then
        return nil
      end
      if diag.label == "copyright" then
        return nil
      end
      diag.source = "cpplint"
      return diag
    end,
    check_exit_code = function(code)
      return code >= 1
    end,
  },
}
