local lspconfig = require "lspconfig"
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = vim.tbl_deep_extend("keep", {}, require("plugins.configs.lspconfig").capabilities)
capabilities.offsetEncoding = { "utf-16" }

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

local configs = {
  clangd = {
    cmd = { "clangd", "--clang-tidy" },
  },
}

for _, lsp in ipairs(servers) do
  local config = configs[lsp] or {}
  config = vim.tbl_deep_extend("force", config, {
    on_attach = on_attach,
    capabilities = capabilities,
  })
  lspconfig[lsp].setup(config)
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
