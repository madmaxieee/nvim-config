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

local function make_diagnostics_filter(to_filter)
  return function(_, params, ctx, config)
    if params.diagnostics ~= nil then
      local idx = 1
      while idx <= #params.diagnostics do
        local code = params.diagnostics[idx].code
        if utils.in_list(to_filter, code) then
          table.remove(params.diagnostics, idx)
        else
          idx = idx + 1
        end
      end
    end
    vim.lsp.diagnostic.on_publish_diagnostics(_, params, ctx, config)
  end
end

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

      local configs = {
        clangd = {
          cmd = { "clangd", "--clang-tidy" },
        },
        ts_ls = {
          handlers = {
            -- 71007: ignore client component props must be serializable error
            ["textDocument/publishDiagnostics"] = make_diagnostics_filter { 71007 },
          },
        },
        jdtls = {
          handlers = {
            -- 16: file is not a project-file
            ["textDocument/publishDiagnostics"] = make_diagnostics_filter { "16" },
          },
        },
        -- managed with lazydev.nvim
        --
        -- lua_ls = {
        --   settings = {
        --     Lua = {
        --       diagnostics = {
        --         globals = { "vim" },
        --       },
        --       workspace = {
        --         library = {
        --           [vim.fn.expand "$VIMRUNTIME/lua"] = true,
        --           [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
        --           [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        --           [vim.fn.expand "${3rd}/luv/library"] = true,
        --         },
        --         maxPreload = 100000,
        --         preloadFileSize = 10000,
        --       },
        --     },
        --   },
        -- },
        typos_lsp = {
          init_options = {
            diagnosticSeverity = "Warning",
          },
        },
        tailwindcss = {
          filetypes = utils.filter_list(
            require("lspconfig.configs.tailwindcss").default_config.filetypes,
            function(item)
              return item ~= "markdown"
            end
          ),
        },
      }

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
