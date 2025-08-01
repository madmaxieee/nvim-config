return {
  name = "trailing-ws-action",
  method = require("null-ls").methods.CODE_ACTION,
  filetypes = {},
  generator = {
    fn = function(params)
      ---@type string
      local line = vim.api.nvim_buf_get_lines(params.bufnr, params.range.row - 1, params.range.end_row, false)[1]
      local col, end_col = line:find "%s+$"
      if col and end_col then
        return {
          {
            title = "remove trailing whitespace!",
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
        }
      end
      return {}
    end,
  },
}
