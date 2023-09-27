local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
capabilities.offsetEncoding = { "utf-16" }

local lspconfig = require "lspconfig"

local servers = {
  -- "html",
  "bashls",
  -- "cssls",
  "clangd",
  -- "pyright",
  -- "tsserver",
  -- "tailwindcss",
  -- "cmake",
  -- "dockerls",
  -- "eslint",
  -- "typst_lsp",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

local custom_servers = {
  ["yamlls"] = {
    yaml = {
      schemas = {
        ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
      },
    },
  },
}

for lsp, config in pairs(custom_servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = config,
  }
end

require("rust-tools").setup {
  server = {
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
    end,
    capabilities = capabilities,
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
