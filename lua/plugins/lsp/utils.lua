local M = {}

---@class DiagFilterOpts
---@field code (number|string)[]?
---@field message string[]?
---@param to_filter DiagFilterOpts
function M.make_diagnostics_filter(to_filter)
  to_filter.code = to_filter.code or {}
  to_filter.message = to_filter.message or {}
  return function(_, params, ctx)
    if params.diagnostics ~= nil then
      local idx = 1
      while idx <= #params.diagnostics do
        local code = params.diagnostics[idx].code
        local message = params.diagnostics[idx].message
        if vim.list_contains(to_filter.code, code) or vim.list_contains(to_filter.message, message) then
          table.remove(params.diagnostics, idx)
        else
          idx = idx + 1
        end
      end
    end
    vim.lsp.diagnostic.on_publish_diagnostics(_, params, ctx)
  end
end

local function get_lsp_global_var(client_name)
  return "LspEnabled_" .. client_name
end

function M.get_lsp_enabled(client_name)
  if client_name == nil or client_name == "" then
    return false
  end
  local var_name = get_lsp_global_var(client_name)
  return vim.g[var_name] ~= 0
end

function M.set_lsp_enabled(client_name, enabled)
  if client_name == nil or client_name == "" then
    return
  end
  local var_name = get_lsp_global_var(client_name)
  if enabled then
    vim.g[var_name] = nil
  else
    vim.g[var_name] = 0
  end
end

return M
