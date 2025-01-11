local lsp_config = require "plugins.lsp.config"

local utils = require "utils"

local servers = {
  "lua_ls",
  "html",
  "cssls",
  "clangd",
  "ruff",
  "pyright",
  "ts_ls",
  "tailwindcss",
  "cmake",
  "dockerls",
  "eslint",
  "yamlls",
  "typos_lsp",
  "typst_lsp",
  "bashls",
  "taplo", -- toml
  "zls",
  "gopls",
  "jdtls",
  "nil_ls",
}

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

local function make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
  capabilities = vim.tbl_deep_extend("force", capabilities, {
    offsetEncoding = { "utf-16" },
  })
  return capabilities
end

return {
  cond = lsp_config.cond(),
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- mason has to configure PATH first
    "williamboman/mason.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    local configs = {
      clangd = {
        cmd = { "clangd", "--clang-tidy" },
      },
      ts_ls = {
        handlers = {
          -- 71007: ignore client component props must be serializable error
          ["textDocument/publishDiagnostics"] = make_diagnostics_filter { code = { 71007 } },
        },
      },
      jdtls = {
        handlers = {
          -- 16: file is not a project-file
          ["textDocument/publishDiagnostics"] = make_diagnostics_filter { code = { "16" } },
        },
      },
      taplo = {
        handlers = {
          ["textDocument/publishDiagnostics"] = make_diagnostics_filter {
            message = { "this document has been excluded" },
          },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            -- -- managed with lazydev.nvim
            -- workspace = {
            --   library = {
            --     [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            --     [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
            --     [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
            --     [vim.fn.expand "${3rd}/luv/library"] = true,
            --   },
            --   maxPreload = 100000,
            --   preloadFileSize = 10000,
            -- },
          },
        },
      },
      typos_lsp = {
        init_options = {
          diagnosticSeverity = "Warning",
        },
      },
      tailwindcss = {
        filetypes = utils.filter_list(require("lspconfig.configs.tailwindcss").default_config.filetypes, function(item)
          return item ~= "markdown"
        end),
      },
    }

    local lspconfig = require "lspconfig"
    local capabilities = make_capabilities()
    for _, lsp in ipairs(servers) do
      local config = configs[lsp] or {}
      config = vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        on_attach = lsp_config.on_attach,
      }, config)
      lspconfig[lsp].setup(config)
    end
  end,
}
