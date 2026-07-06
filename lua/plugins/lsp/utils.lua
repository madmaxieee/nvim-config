local M = {}

local function match_any(patterns, str)
  if not str then
    return false
  end
  for _, pattern in ipairs(patterns) do
    if string.match(str, pattern) then
      return true
    end
  end
  return false
end

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
        if
          vim.list_contains(to_filter.code, code)
          or match_any(to_filter.message, message)
        then
          table.remove(params.diagnostics, idx)
        else
          idx = idx + 1
        end
      end
    end
    vim.lsp.diagnostic.on_publish_diagnostics(_, params, ctx)
  end
end

---@param bufnr number?
function M.make_rename_filter(bufnr)
  ---@diagnostic disable-next-line: unused-local
  local ft = vim.bo[bufnr or 0].filetype
  ---@param client vim.lsp.Client
  ---@diagnostic disable-next-line: unused-local
  return function(client)
    return true
  end
end

local default_disabled_lsp = {
  ["copilot"] = true,
  ["cpplint"] = true,
  ["harper_ls"] = true,
}

---@param client_name string
local function get_lsp_global_var(client_name)
  return "LspEnabled_" .. client_name
end

---@param client_name string
function M.lsp_should_enable(client_name)
  if client_name == nil or client_name == "" then
    return false
  end
  local var_name = get_lsp_global_var(client_name)
  if vim.g[var_name] == nil then
    if default_disabled_lsp[client_name] then
      return false
    else
      return true
    end
  elseif vim.g[var_name] == 1 then
    return true
  elseif vim.g[var_name] == 0 then
    return false
  end
end

---@param client_name string
---@param enabled boolean
local function set_lsp_enabled_var(client_name, enabled)
  if client_name == nil or client_name == "" then
    return
  end
  local var_name = get_lsp_global_var(client_name)
  if default_disabled_lsp[client_name] then
    if enabled then
      vim.g[var_name] = 1
    else
      vim.g[var_name] = nil
    end
  else
    if enabled then
      vim.g[var_name] = nil
    else
      vim.g[var_name] = 0
    end
  end
end

function M.lsp_enable(server)
  set_lsp_enabled_var(server, true)
  if vim.lsp.config[server] then
    if vim.fn.exists(":lsp") ~= 0 then
      vim.cmd("lsp enable " .. server)
      vim.diagnostic.reset(nil, 0)
    elseif vim.fn.exists(":LspStart") ~= 0 then
      vim.cmd("LspStart " .. server)
      vim.diagnostic.reset(nil, 0)
    end
  end
end

function M.lsp_disable(server)
  set_lsp_enabled_var(server, false)
  if vim.lsp.config[server] then
    if vim.fn.exists(":lsp") ~= 0 then
      vim.cmd("lsp disable " .. server)
      vim.diagnostic.reset(nil, 0)
    elseif vim.fn.exists(":LspStop") ~= 0 then
      vim.cmd("LspStop " .. server)
      vim.diagnostic.reset(nil, 0)
    end
  end
end

return M
