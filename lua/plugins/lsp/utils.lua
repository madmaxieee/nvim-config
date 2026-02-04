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
        if
          vim.list_contains(to_filter.code, code)
          or vim.list_contains(to_filter.message, message)
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

local no_format = {
  ["eslint"] = true, -- don't auto fix eslint errors
  ["cmake"] = true,
}
---@param bufnr number?
function M.make_formatter_filter(bufnr)
  local ft = vim.bo[bufnr or 0].filetype

  ---@param client vim.lsp.Client
  local function formatter_filter(client)
    if no_format[client.name] then
      return false
    end
    local null_ls = require("null-ls")
    if ft == "lua" and null_ls.is_registered("stylua") then
      return client.name == "null-ls"
    end
    if
      vim.tbl_contains({
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
        "svelte",
      }, ft)
    then
      if null_ls.is_registered("prettierd") then
        return client.name == "null-ls"
      end
    end
    if ft == "java" and null_ls.is_registered("google-java-format") then
      return client.name == "null-ls"
    end
    if ft == "python" and null_ls.is_registered("pyformat") then
      return client.name == "null-ls"
    end
    return true
  end

  return formatter_filter
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
  if vim.fn.exists(":lsp") ~= 0 then
    vim.cmd("lsp enable " .. server)
    vim.diagnostic.reset(nil, 0)
  elseif vim.fn.exists(":LspStart") ~= 0 then
    vim.cmd("LspStart " .. server)
    vim.diagnostic.reset(nil, 0)
  end
end

function M.lsp_disable(server)
  set_lsp_enabled_var(server, false)
  if vim.fn.exists(":lsp") ~= 0 then
    vim.cmd("lsp disable " .. server)
    vim.diagnostic.reset(nil, 0)
  elseif vim.fn.exists(":LspStop") ~= 0 then
    vim.cmd("LspStop " .. server)
    vim.diagnostic.reset(nil, 0)
  end
end

function M.null_ls_enable(source_name, source)
  local null_ls = require("null-ls")
  set_lsp_enabled_var(source_name, true)
  if null_ls.is_registered(source_name) then
    null_ls.enable(source_name)
  else
    null_ls.register(source)
  end
end

function M.null_ls_disable(source_name)
  local null_ls = require("null-ls")
  set_lsp_enabled_var(source_name, false)
  if null_ls.is_registered(source_name) then
    null_ls.disable(source_name)
  end
end

return M
