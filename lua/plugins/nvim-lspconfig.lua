local map = require("utils").safe_keymap_set

local function set_keymaps(bufnr)
  map("n", "gd", function()
    vim.lsp.buf.definition()
  end, { buffer = bufnr, desc = "Go to definition" })

  map("n", "gD", function()
    vim.lsp.buf.type_definition()
  end, { buffer = bufnr, desc = "Go to type definition" })

  map("n", "K", function()
    vim.lsp.buf.hover()
  end, { buffer = bufnr, desc = "Hover" })

  map("n", "gi", function()
    vim.lsp.buf.implementation()
  end, { buffer = bufnr, desc = "Go to implementation" })

  map("n", "<leader>ls", function()
    vim.lsp.buf.signature_help()
  end, { buffer = bufnr, desc = "Signature help" })

  map("n", "[d", function()
    vim.lsp.diagnostic.goto_prev()
  end, { buffer = bufnr, desc = "Go to previous diagnostic" })

  map("n", "]d", function()
    vim.lsp.diagnostic.goto_next()
  end, { buffer = bufnr, desc = "Go to next diagnostic" })

  map("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
  end, { buffer = bufnr, desc = "LSP code action" })

  map("n", "gr", function()
    vim.lsp.buf.references()
  end, { buffer = bufnr, desc = "LSP references" })

  map("n", "<leader>ra", function()
    vim.lsp.buf.rename()
  end, { buffer = bufnr, desc = "LSP rename" })

  map("n", "<leader>q", function()
    vim.diagnostic.setloclist()
  end, { buffer = bufnr, desc = "Diagnostic setloclist" })

  map("n", "<leader>wa", function()
    vim.lsp.buf.add_workspace_folder()
  end, { buffer = bufnr, desc = "Add workspace folder" })

  map("n", "<leader>wr", function()
    vim.lsp.buf.remove_workspace_folder()
  end, { buffer = bufnr, desc = "Remove workspace folder" })

  map("n", "<leader>wa", function()
    vim.lsp.buf.list_workspace_folders()
  end, { buffer = bufnr, desc = "List workspace folders" })
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
    event = { "BufReadPre", "BufNewFile" },
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
