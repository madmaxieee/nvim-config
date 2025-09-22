return {
  name = "trailing-ws-action",
  method = require("null-ls").methods.CODE_ACTION,
  filetypes = {},
  generator = {
    fn = function(params)
      if
        vim.o.readonly
        or params.ft == "diff"
        or params.ft == "log"
        -- from snacks bigfile
        or params.ft == "bigfile"
      then
        return
      end
      ---@type string
      local line = vim.api.nvim_buf_get_lines(params.bufnr, params.range.row - 1, params.range.end_row, false)[1]
      local col, end_col = line:find "%s+$"
      if col and end_col then
        return {
          {
            title = "remove trailing whitespace on this line!",
            action = function()
              local replacement = line:gsub("%s+$", "")
              vim.api.nvim_buf_set_lines(
                params.bufnr,
                params.range.row - 1,
                params.range.end_row,
                false,
                { replacement }
              )
            end,
          },
          {
            title = "remove trailing whitespace in this file!",
            action = function()
              local replacement = {}
              for i, _line in ipairs(vim.api.nvim_buf_get_lines(params.bufnr, 0, -1, false)) do
                replacement[i] = _line:gsub("%s+$", "")
              end
              vim.api.nvim_buf_set_lines(params.bufnr, 0, -1, false, replacement)
            end,
          },
        }
      end
      return {}
    end,
  },
}
