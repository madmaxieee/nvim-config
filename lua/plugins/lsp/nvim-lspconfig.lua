local utils = require "utils"
local lsp_config = require "plugins.lsp.config"

---@class DiagFilterOpts
---@field code (number|string)[]?
---@field message string[]?
---@param to_filter DiagFilterOpts
local function make_diagnostics_filter(to_filter)
  to_filter.code = to_filter.code or {}
  to_filter.message = to_filter.message or {}
  return function(_, params, ctx, config)
    if params.diagnostics ~= nil then
      local idx = 1
      while idx <= #params.diagnostics do
        local code = params.diagnostics[idx].code
        local message = params.diagnostics[idx].message
        if utils.in_list(to_filter.code, code) or utils.in_list(to_filter.message, message) then
          table.remove(params.diagnostics, idx)
        else
          idx = idx + 1
        end
      end
    end
    vim.lsp.diagnostic.on_publish_diagnostics(_, params, ctx, config)
  end
end

local servers = {
  "bashls",
  "clangd",
  "cmake",
  "cssls",
  "dockerls",
  "eslint",
  "gopls",
  "html",
  "jdtls",
  "lua_ls",
  "nil_ls",
  "pyright",
  "ruff",
  "rust_analyzer",
  "tailwindcss",
  "taplo", -- toml
  "tinymist",
  "ts_ls",
  "typos_lsp",
  "yamlls",
  "zls",
}

local server_configs = {
  clangd = {
    cmd = { "clangd", "--clang-tidy" },
  },
  jdtls = {
    handlers = {
      -- 16: file is not a project-file
      ["textDocument/publishDiagnostics"] = make_diagnostics_filter { code = { "16" } },
    },
  },
  tailwindcss = function()
    local original_ft = require("lspconfig.configs.tailwindcss").default_config.filetypes
    return {
      filetypes = utils.filter_list(original_ft, function(item)
        return item ~= "markdown"
      end),
    }
  end,
  taplo = {
    handlers = {
      ["textDocument/publishDiagnostics"] = make_diagnostics_filter {
        message = { "this document has been excluded" },
      },
    },
  },
  ts_ls = {
    handlers = {
      -- 71007: ignore client component props must be serializable error
      ["textDocument/publishDiagnostics"] = make_diagnostics_filter { code = { 71007 } },
    },
  },
  typos_lsp = {
    init_options = {
      diagnosticSeverity = "Warning",
    },
  },
}

local external_servers = {
  nil_ls = true,
}

return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = utils.filter_list(servers, function(item)
        return not external_servers[item]
      end),
    },
  },

  {
    cond = lsp_config.cond(),
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require "lspconfig"
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
      for _, lsp in ipairs(servers) do
        local config = server_configs[lsp]
        if type(config) == "function" then
          config = config()
        end
        config = config or {}
        config.capabilities = capabilities
        config.on_attach = lsp_config.on_attach
        lspconfig[lsp].setup(config)
      end
    end,
  },
}
