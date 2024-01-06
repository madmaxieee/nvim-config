local map = require("utils").safe_keymap_set

local function set_keymaps(bufnr)
  if vim.b[bufnr].lsp_keymaps_set then
    return
  end

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

  map("n", "<leader>fm", function()
    vim.lsp.buf.format { async = true }
  end, { buffer = bufnr, desc = "LSP formatting" })

  vim.b[bufnr].lsp_keymaps_set = true
end

local lsp_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})

local function on_attach(client, bufnr)
  set_keymaps(bufnr)
  if not client then
    return
  end
  if client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
  if client.supports_method "textDocument/formatting" then
    vim.api.nvim_clear_autocmds { group = lsp_formatting_group, buffer = bufnr }
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = lsp_formatting_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format {
          async = false,
          filter = function(_client)
            return _client.name ~= "lua_ls" -- use stylua instead
          end,
        }
      end,
    })
  end
end

return on_attach
