local utils = require "utils"

vim.api.nvim_create_user_command("DetachLsp", function()
  vim.diagnostic.reset(nil, 0)
  local clients = vim.lsp.get_clients { bufnr = 0 }
  vim.schedule(function()
    for _, client in ipairs(clients) do
      vim.lsp.buf_detach_client(0, client.id)
    end
  end)
end, {})

-- disable lsp for certain filetypes and in diff mode
local disable_lsp_group = vim.api.nvim_create_augroup("DisableLsp", { clear = true })

local no_lsp_filetype = {
  ["toggleterm"] = true,
  ["help"] = true,
  ["log"] = true,
}

local no_lsp_file_pattern = {
  [[/?%.env]],
}

local function detach_client(client_id, bufnr)
  vim.schedule(function()
    vim.lsp.buf_detach_client(bufnr, client_id)
    vim.diagnostic.reset(nil, bufnr)
  end)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = disable_lsp_group,
  callback = function(args)
    local bufnr = args.buf
    local client_id = args.data.client_id
    if no_lsp_filetype[vim.bo[bufnr].filetype] or vim.wo.diff then
      detach_client(client_id, bufnr)
      return
    end
    local filename = vim.api.nvim_buf_get_name(bufnr)
    for _, pattern in ipairs(no_lsp_file_pattern) do
      if filename:match(pattern) then
        detach_client(client_id, bufnr)
        return
      end
    end
  end,
})

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
    dependencies = {
      -- mason has to configure PATH first
      "williamboman/mason.nvim",
      "saghen/blink.cmp",
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
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              -- -- managed with lazydev.nvim
              -- workspace = {
              --   library = {
              --     [vim.fn.expand "$VIMRUNTIME/lua"] = true,
              --     [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
              --     [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
              --     [vim.fn.expand "${3rd}/luv/library"] = true,
              --   },
              --   maxPreload = 100000,
              --   preloadFileSize = 10000,
              -- },
            },
          },
        },
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

      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
      for _, lsp in ipairs(servers) do
        local config = configs[lsp] or {}
        config = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, config)
        lspconfig[lsp].setup(config)
      end
    end,
  },

  {
    cond = not vim.g.minimal_mode,
    "simrat39/rust-tools.nvim",
    ft = "rust",
    config = function()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
      require("rust-tools").setup {
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
      }
    end,
  },
}
