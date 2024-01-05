local map = require("utils").safe_keymap_set

local function set_keymaps(bufnr)
  map("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
  map("n", "gD", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Go to type definition" })
  map("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
  map("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
  map("n", "<leader>ls", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature help" })
  map("n", "[d", vim.lsp.diagnostic.goto_prev, { buffer = bufnr, desc = "Go to previous diagnostic" })
  map("n", "]d", vim.lsp.diagnostic.goto_next, { buffer = bufnr, desc = "Go to next diagnostic" })
  map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP code action" })
  map("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "LSP references" })
  map("n", "<leader>ra", vim.lsp.buf.rename, { buffer = bufnr, desc = "LSP rename" })
  map("n", "<leader>q", vim.diagnostic.setloclist, { buffer = bufnr, desc = "Diagnostic setloclist" })
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { buffer = bufnr, desc = "Add workspace folder" })
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { buffer = bufnr, desc = "Remove workspace folder" })
  map("n", "<leader>wa", vim.lsp.buf.list_workspace_folders, { buffer = bufnr, desc = "List workspace folders" })
end

local servers = {
  "lua_ls",
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
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
            [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
            [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
local function on_attach(client, bufnr)
  set_keymaps(bufnr)
  if client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    -- mason has to configure PATH first
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      local lspconfig = require "lspconfig"
      for _, lsp in ipairs(servers) do
        local config = configs[lsp] or {}
        config = vim.tbl_deep_extend("force", config, {
          capabilities = capabilities,
          on_attach = on_attach,
        })
        lspconfig[lsp].setup(config)
      end
    end,
  },
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    opts = {
      server = {
        capabilities = vim.lsp.protocol.make_client_capabilities(),
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
    },
  },
}
