return {
  name = "trailing-ws",
  method = require("null-ls").methods.DIAGNOSTICS,
  filetypes = {},
  generator = {
    fn = function(params)
      if
        vim.o.readonly
        or params.ft == "diff"
        or params.ft == "log"
        or params.ft == "hgcommit"
        -- from snacks bigfile
        or params.ft == "bigfile"
      then
        return
      end
      local diagnostics = {}
      for i, line in ipairs(params.content) do
        local col, end_col = line:find("%s+$")
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
