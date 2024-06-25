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
  "bashls",
  "taplo", -- toml
  "zls",
  "gopls",
  "jdtls",
}

local configs = {
  clangd = {
    cmd = { "clangd", "--clang-tidy" },
  },
  tsserver = {
    handlers = {
      ["textDocument/publishDiagnostics"] = function(_, params, ctx, config)
        if params.diagnostics ~= nil then
          local idx = 1
          while idx <= #params.diagnostics do
            local code = params.diagnostics[idx].code
            -- ignore client component props must be serializable error
            if code == 71007 then
              table.remove(params.diagnostics, idx)
            else
              idx = idx + 1
            end
          end
        end
        vim.lsp.diagnostic.on_publish_diagnostics(_, params, ctx, config)
      end,
    },
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

local capabilities =
  vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), { offsetEncoding = { "utf-16" } })
local on_attach = require "plugins.lsp.on_attach"

return {
  {
    cond = not vim.g.minimal_mode,
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
    cond = not vim.g.minimal_mode,
    "simrat39/rust-tools.nvim",
    ft = "rust",
    opts = {
      server = {
        capabilities = capabilities,
        on_attach = on_attach,
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
