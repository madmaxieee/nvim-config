local map = require("utils").safe_keymap_set

local no_format = {
  ["eslint"] = true, -- don't auto fix eslint errors
  ["cmake"] = true,
}

local function formatter_filter(client)
  if no_format[client.name] then
    return false
  end
  ---@diagnostic disable-next-line: different-requires
  local null_ls = require "null-ls"
  if client.name == "ts_ls" and null_ls.is_registered "prettierd" then
    return false
  end
  if client.name == "lua_ls" and null_ls.is_registered "stylua" then
    return false
  end
  return true
end

local function set_keymaps(bufnr)
  if vim.b[bufnr].lsp_keymaps_set then
    return
  end

  local trouble_open = require("trouble").open

  map("n", "gd", function()
    -- vim.lsp.buf.definition()
    trouble_open { mode = "lsp_definitions" }
  end, { buffer = bufnr, desc = "Go to definition" })

  map("n", "gD", function()
    -- vim.lsp.buf.type_definition()
    trouble_open { mode = "lsp_type_definitions" }
  end, { buffer = bufnr, desc = "Go to type definition" })

  map("n", "K", function()
    vim.lsp.buf.hover()
  end, { buffer = bufnr, desc = "Hover" })

  map("n", "gi", function()
    -- vim.lsp.buf.implementation()
    trouble_open { mode = "lsp_implementations" }
  end, { buffer = bufnr, desc = "Go to implementation" })

  map("n", "<leader>ls", function()
    vim.lsp.buf.signature_help()
  end, { buffer = bufnr, desc = "Signature help" })

  local map_repeatable_pair = require("utils").map_repeatable_pair
  map_repeatable_pair("n", {
    next = {
      "]d",
      function()
        vim.diagnostic.goto_next { float = { border = "rounded" } }
      end,
      { buffer = bufnr, desc = "Go to next diagnostic" },
    },
    prev = {
      "[d",
      function()
        vim.diagnostic.goto_prev { float = { border = "rounded" } }
      end,
      { buffer = bufnr, desc = "Go to previous diagnostic" },
    },
  })

  map("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
  end, { buffer = bufnr, desc = "LSP code action" })

  map("n", "gr", function()
    -- vim.lsp.buf.references()
    trouble_open { mode = "lsp_references" }
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

  vim.b[bufnr].lsp_keymaps_set = true
end

local lsp_formatting_group = vim.api.nvim_create_augroup("LspFormatting", {})

local function on_attach(client, bufnr)
  set_keymaps(bufnr)
  if not client then
    return
  end
  client.server_capabilities.semanticTokensProvider = nil
  if client.supports_method "textDocument/formatting" or client.name == "jdtls" then
    vim.api.nvim_clear_autocmds { group = lsp_formatting_group, buffer = bufnr }
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = lsp_formatting_group,
      buffer = bufnr,
      callback = function()
        if vim.g.FormatOnSave == 0 then
          return
        end
        vim.lsp.buf.format {
          async = false,
          filter = formatter_filter,
        }
      end,
    })
  end
end

vim.api.nvim_create_user_command("EnableFormatOnSave", function()
  vim.g.FormatOnSave = 1
end, {})

vim.api.nvim_create_user_command("DisableFormatOnSave", function()
  vim.g.FormatOnSave = 0
end, {})

vim.api.nvim_create_user_command("FormatBuffer", function()
  vim.lsp.buf.format {
    async = true,
    filter = formatter_filter,
  }
end, {})

return on_attach
