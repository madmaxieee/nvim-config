local utils = require "utils"
local lsp_utils = require "plugins.lsp.utils"

utils.on_load("nvim-lspconfig", function()
  -- http://cl/783896564
  vim.lsp.config("ciderlsp", {
    cmd = {
      "/google/bin/releases/cider/ciderlsp/ciderlsp",
      "--tooltag=nvim-lsp",
      "--noforward_sync_responses",
      "--cdpush_name=",
    },
    filetypes = {
      "borg",
      "bzl",
      "c",
      "cpp",
      "cs",
      "dart",
      "gcl",
      "go",
      "googlesql",
      "graphql",
      "java",
      "kotlin",
      "markdown",
      "mlir",
      "ncl",
      "objc",
      "patchpanel",
      "proto",
      "python",
      "qflow",
      "soy",
      "swift",
      "textpb",
      "typescript",
    },
    root_dir = function(bufnr, cb)
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local root_dir = string.match(fname, "(/google/src/cloud/[%w_-]+/[%w_-]+/).+$")
      if root_dir then
        cb(root_dir)
      end
    end,
  })
  vim.lsp.enable "ciderlsp"

  local ciderlsp_attach_once_group = vim.api.nvim_create_augroup("ciderlsp.attach.once", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = ciderlsp_attach_once_group,
    callback = function(args)
      local ciderlsp_client = vim.lsp.get_client_by_id(args.data.client_id)
      if ciderlsp_client and ciderlsp_client.name == "ciderlsp" then
        -- disable lsps for languages ciderlsp supports
        for _, name in ipairs {
          "clangd",
          "copilot",
          "eslint",
          "gopls",
          "jdtls",
          "ruff",
          "ts_ls",
        } do
          vim.cmd("LspStop " .. name)
        end

        -- enable pyright for type checking even if ciderlsp is attached
        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("ciderlsp.other", { clear = true }),
          callback = function(_args)
            local client = vim.lsp.get_client_by_id(_args.data.client_id)
            if not client then
              return
            end
            if client.name == "pyright" then
              client.server_capabilities.completionProvider = nil
              client.server_capabilities.definitionProvider = nil
              -- client.server_capabilities.diagnosticProvider = nil
              client.server_capabilities.documentHighlightProvider = nil
              client.server_capabilities.documentSymbolProvider = nil
              client.server_capabilities.hoverProvider = nil
              client.server_capabilities.implementationProvider = nil
              client.server_capabilities.inlayHintProvider = nil
              client.server_capabilities.referencesProvider = nil
              client.server_capabilities.renameProvider = nil
              client.server_capabilities.semanticTokensProvider = nil
              client.server_capabilities.signatureHelpProvider = nil
              client.server_capabilities.typeDefinitionProvider = nil
              client.server_capabilities.workspaceSymbolProvider = nil
            end
          end,
        })
        vim.lsp.config("pyright", {
          handlers = {
            -- can't find deps not in google3
            ["textDocument/publishDiagnostics"] = lsp_utils.make_diagnostics_filter { code = { "reportMissingImports" } },
          },
        })
        vim.cmd "LspRestart pyright"

        vim.api.nvim_del_augroup_by_id(ciderlsp_attach_once_group)
      end
    end,
  })
end)

vim.filetype.add {
  extension = {
    gcl = "gcl",
  },
}

-- this file is imported as a lazy.nvim spec file
return {}
