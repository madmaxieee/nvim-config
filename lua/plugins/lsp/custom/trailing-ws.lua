return {
  name = "trailing-ws",
  method = require("null-ls").methods.DIAGNOSTICS,
  filetypes = {},
  generator = {
    fn = function(params)
      local diagnostics = {}
      for i, line in ipairs(params.content) do
        local col, end_col = line:find "%s+$"
        if col and end_col then
          table.insert(diagnostics, {
            row = i,
            col = col,
            end_col = end_col + 1,
            source = "trailing-ws",
            message = "no trailing whitespace!",
            severity = vim.diagnostic.severity.WARN,
          })
        end
      end
      return diagnostics
    end,
  },
}
