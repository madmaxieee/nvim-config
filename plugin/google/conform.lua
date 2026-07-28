if not require("flags").in_google3 then
  return
end

local conform = require("conform")

local orig_formatters_by_ft = vim.deepcopy(conform.formatters_by_ft)

---@param ft string
---@param bufnr integer
local function get_orig_formatters_by_ft(ft, bufnr)
  local formatters = orig_formatters_by_ft[ft]
  if type(formatters) == "table" then
    return formatters
  elseif type(formatters) == "function" then
    return formatters(bufnr)
  end
end

-- markdown
conform.formatters.google_mdformat = {
  command = "/google/bin/releases/corpeng-engdoc/tools/mdformat",
  args = { "-" },
  stdin = true,
}
conform.formatters.google_mdformat_compat = {
  command = "/google/bin/releases/corpeng-engdoc/tools/mdformat",
  args = { "--compatibility", "-" },
  stdin = true,
}

conform.formatters_by_ft.markdown = function(bufnr)
  if conform.get_formatter_info("google_mdformat", bufnr).available then
    return { "google_mdformat" }
  else
    return get_orig_formatters_by_ft("markdown", bufnr)
  end
end

vim.api.nvim_create_user_command("MdformatCompat", function()
  conform.format({ formatters = { "google_mdformat_compat" } })
end, {})

-- python
conform.formatters.pyformat = {
  command = "pyformat",
  args = {},
  stdin = true,
}

conform.formatters_by_ft.python = function(bufnr)
  if conform.get_formatter_info("pyformat", bufnr).available then
    return { "pyformat" }
  else
    return get_orig_formatters_by_ft("python", bufnr)
  end
end
