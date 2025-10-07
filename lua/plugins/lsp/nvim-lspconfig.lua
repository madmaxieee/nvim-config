local lsp_config = require "plugins.lsp.config"
local lsp_utils = require "plugins.lsp.utils"

local servers = {
  "bacon_ls",
  "bashls",
  "clangd",
  "cmake",
  "copilot",
  "cssls",
  "dockerls",
  "eslint",
  "gopls",
  "html",
  "jdtls",
  "jsonls",
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

---@type table<string, vim.lsp.Config | fun(): vim.lsp.Config>
local server_configs = {
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--fallback-style=google",
      "--header-insertion=iwyu",
    },
  },
  jdtls = {
    handlers = {
      -- 16: file is not a project-file
      ["textDocument/publishDiagnostics"] = lsp_utils.make_diagnostics_filter { code = { "16" } },
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
      filetypes = vim.tbl_filter(function(item)
        return item ~= "markdown"
      end, original_ft),
    }
  end,
  taplo = {
    handlers = {
      ["textDocument/publishDiagnostics"] = lsp_utils.make_diagnostics_filter {
        message = { "this document has been excluded" },
      },
    },
  },
  ts_ls = {
    handlers = {
      -- 71007: ignore client component props must be serializable error
      ["textDocument/publishDiagnostics"] = lsp_utils.make_diagnostics_filter { code = { 71007 } },
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
    init = function()
      vim.api.nvim_create_user_command("LspEnable", function(opts)
        if not vim.tbl_contains(servers, opts.args) then
          vim.notify(("Unknown LSP server: %s"):format(opts.args), vim.log.levels.ERROR)
          return
        end
        lsp_utils.set_lsp_enabled(opts.args, true)
        vim.cmd("LspRestart " .. opts.args)
        vim.diagnostic.reset(nil, 0)
      end, {
        nargs = 1,
        complete = function()
          return servers
        end,
      })

      vim.api.nvim_create_user_command("LspDisable", function(opts)
        if not vim.tbl_contains(servers, opts.args) then
          vim.notify(("Unknown LSP server: %s"):format(opts.args), vim.log.levels.ERROR)
          return
        end
        lsp_utils.set_lsp_enabled(opts.args, false)
        vim.cmd("LspStop " .. opts.args)
        vim.diagnostic.reset(nil, 0)
      end, {
        nargs = 1,
        complete = function()
          return servers
        end,
      })

      vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = vim.api.nvim_create_augroup("lspconfig.global_var_disable", { clear = true }),
        callback = function()
          for _, lsp in ipairs(servers) do
            if not lsp_utils.get_lsp_enabled(lsp) then
              vim.cmd("LspStop " .. lsp)
            end
          end
          vim.diagnostic.reset(nil, 0)
        end,
      })

      require "plugins.lsp.copilot"
    end,
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
      vim.lsp.config("*", { capabilities = capabilities })
      for lsp, config in pairs(server_configs) do
        if type(config) == "function" then
          config = config()
        end
        vim.lsp.config(lsp, config)
      end
      vim.lsp.enable(servers)
    end,
  },
}
