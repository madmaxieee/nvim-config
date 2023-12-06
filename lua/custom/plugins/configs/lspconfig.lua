local lspconfig = require "lspconfig"
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
capabilities.offsetEncoding = { "utf-16" }

local capabilities_no_semantic = vim.tbl_deep_extend("keep", {}, capabilities)
capabilities_no_semantic.semanticTokensProvider = nil

local servers = {
  "html",
  "cssls",
  "clangd",
  "pyright",
  "tsserver",
  "tailwindcss",
  "cmake",
  "dockerls",
  "eslint",
  "yamlls",
  "typos_lsp",
  "typst_lsp",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities_no_semantic,
  }
end

require("rust-tools").setup {
  server = {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
    end,
    capabilities = capabilities_no_semantic,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },
  tools = {
    hover_actions = {
      auto_focus = true,
    },
  },
}
