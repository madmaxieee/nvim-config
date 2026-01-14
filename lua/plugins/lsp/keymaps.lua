local M = {}

local utils = require("utils")
local map = utils.safe_keymap_set

function M.set_keymaps(bufnr)
  if vim.b[bufnr].lsp_keymaps_set then
    return
  end

  map("n", "K", function()
    vim.lsp.buf.hover()
  end, { buffer = bufnr, desc = "Hover" })

  map("n", "gd", function()
    -- vim.lsp.buf.definition()
    require("trouble").open({ mode = "lsp_definitions" })
  end, { buffer = bufnr, desc = "Go to definition" })

  map("n", "gD", function()
    -- vim.lsp.buf.type_definition()
    require("trouble").open({ mode = "lsp_type_definitions" })
  end, { buffer = bufnr, desc = "Go to type definition" })

  map("n", "gr", function()
    -- vim.lsp.buf.references()
    require("trouble").open({ mode = "lsp_references" })
  end, { buffer = bufnr, desc = "LSP references" })

  map("n", "gi", function()
    -- vim.lsp.buf.implementation()
    require("trouble").open({ mode = "lsp_implementations" })
  end, { buffer = bufnr, desc = "Go to implementation" })

  map("n", "<leader>ls", function()
    vim.lsp.buf.signature_help()
  end, { buffer = bufnr, desc = "Signature help" })

  utils.map_repeatable_pair("n", {
    next = {
      "]d",
      function()
        vim.diagnostic.jump({ count = 1 })
      end,
      { buffer = bufnr, desc = "Go to next diagnostic" },
    },
    prev = {
      "[d",
      function()
        vim.diagnostic.jump({ count = -1 })
      end,
      { buffer = bufnr, desc = "Go to previous diagnostic" },
    },
  })

  map("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
  end, { buffer = bufnr, desc = "LSP code action" })

  map("n", "<leader>ra", function()
    vim.lsp.buf.rename()
  end, { buffer = bufnr, desc = "LSP rename" })

  vim.b[bufnr].lsp_keymaps_set = true
end

return M
