local lsp_config = require("plugins.lsp.config")
local lsp_utils = require("plugins.lsp.utils")

local servers = {
  "bashls",
  "clangd",
  "cmake",
  "copilot",
  "cssls",
  "dockerls",
  "eslint",
  "gopls",
  "harper_ls",
  "html",
  "jdtls",
  "jsonls",
  "lemminx",
  "lua_ls",
  "nil_ls",
  "pyright",
  "ruff",
  "rust_analyzer",
  "svelte",
  "tailwindcss",
  "taplo",
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
      ["textDocument/publishDiagnostics"] = lsp_utils.make_diagnostics_filter({
        code = { "16" },
      }),
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "require" },
        },
        hint = {
          enable = true,
          arrayIndex = "Disable",
        },
      },
    },
  },
  nil_ls = {
    settings = {
      ["nil"] = {
        nix = {
          flake = {
            autoArchive = true,
          },
        },
      },
    },
  },
  rust_analyzer = function()
    if vim.env.ANDROID_BUILD_TOP then
      local android_root = vim.env.ANDROID_BUILD_TOP
      return {
        cmd = {
          android_root
            .. "/prebuilts/rust-toolchain/linux-x86/stable/rust-analyzer",
        },
        settings = {
          ["rust-analyzer"] = {
            rustfmt = {
              extraArgs = {
                "--config-path",
                (android_root .. "/build/soong/scripts/rustfmt.toml"),
              },
            },
            linkedProjects = { (android_root .. "/rust-project.json") },
            procMacro = { enable = false },
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
    root_dir = vim.uv.cwd() or vim.fn.getcwd(),
    handlers = {
      ["textDocument/publishDiagnostics"] = lsp_utils.make_diagnostics_filter({
        message = { "this document has been excluded" },
      }),
    },
  },
  ts_ls = {
    handlers = {
      -- 71007: ignore client component props must be serializable error
      ["textDocument/publishDiagnostics"] = lsp_utils.make_diagnostics_filter({
        code = { 71007 },
      }),
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
    cond = not require("modes").minimal_mode,
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    init = function()
      lsp_config.init({ servers = servers })
    end,
    config = function()
      lsp_config.setup({
        servers = servers,
        server_configs = server_configs,
      })
    end,
  },
}
