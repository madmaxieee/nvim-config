local utils = require "utils"
local lsp_config = require "plugins.lsp.config"
local make_diagnostics_filter = require("plugins.lsp.utils").make_diagnostics_filter

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
    cmd = {
      "clangd",
      "--clang-tidy",
      "--fallback-style=google",
      -- neovim does not support multiple offset encoding
      "--offset-encoding=utf-16",
    },
  },
  jdtls = {
    handlers = {
      -- 16: file is not a project-file
      ["textDocument/publishDiagnostics"] = make_diagnostics_filter { code = { "16" } },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "require" },
        },
      },
    },
  },
  rust_analyzer = function()
    if vim.env.ANDROID_BUILD_TOP then
      return {
        cmd = { ("%s/prebuilts/rust/linux-x86/stable/rust-analyzer"):format(vim.env.ANDROID_BUILD_TOP) },
        rustfmt = {
          extraArgs = {
            "--config-path",
            ("%s/build/soong/scripts/rustfmt.toml"):format(vim.env.ANDROID_BUILD_TOP),
          },
        },
      }
    else
      return {}
    end
  end,
  tailwindcss = function()
    local original_ft = vim.lsp.config["tailwindcss"].filetypes or {}
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
  zls = {
    settings = {
      zls = {
        enable_build_on_save = true,
      },
    },
  },
}

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- needed for bashls
        "shellcheck",
        "shfmt",
      },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = servers,
      automatic_enable = false,
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
      vim.lsp.enable(servers)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
      vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = lsp_config.on_attach,
      })
      for lsp, config in pairs(server_configs) do
        if type(config) == "function" then
          ---@diagnostic disable-next-line: cast-local-type
          config = config()
        end
        vim.lsp.config(lsp, config)
      end
    end,
  },
}
