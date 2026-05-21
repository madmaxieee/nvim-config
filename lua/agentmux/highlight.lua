local context = require("agentmux.context")

---Parse text for @context placeholders and return highlight tuples for snacks.input.
---Format: { start_col (0-indexed), end_col (0-indexed), hl_group }
---@param text string
---@return { [1]: integer, [2]: integer, [3]: string }[]
local function M(text)
  local highlights = {}
  -- Sort keys by length descending so longer placeholders match first
  local keys = vim.tbl_keys(context.contexts)
  table.sort(keys, function(a, b)
    return #a > #b
  end)

  local i = 1
  while i <= #text do
    local matched = false
    for _, key in ipairs(keys) do
      local placeholder = "@" .. key
      if text:sub(i, i + #placeholder - 1) == placeholder then
        table.insert(
          highlights,
          { i - 1, i - 1 + #placeholder, "AgentMuxContext" }
        )
        i = i + #placeholder
        matched = true
        break
      end
    end
    if not matched then
      i = i + 1
    end
  end

  return highlights
end

return M