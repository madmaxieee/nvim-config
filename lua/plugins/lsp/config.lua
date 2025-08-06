local M = {}

local utils = require "utils"
local map = utils.safe_keymap_set

local function set_keymaps(bufnr)
  if vim.b[bufnr].lsp_keymaps_set then
    return
  end

  local trouble_open = require("trouble").open

  map("n", "K", function()
    vim.lsp.buf.hover()
  end, { buffer = bufnr, desc = "Hover" })

  map("n", "gd", function()
    -- vim.lsp.buf.definition()
    trouble_open { mode = "lsp_definitions" }
  end, { buffer = bufnr, desc = "Go to definition" })

  map("n", "gD", function()
    -- vim.lsp.buf.type_definition()
    trouble_open { mode = "lsp_type_definitions" }
  end, { buffer = bufnr, desc = "Go to type definition" })

  map("n", "gr", function()
    -- vim.lsp.buf.references()
    trouble_open { mode = "lsp_references" }
  end, { buffer = bufnr, desc = "LSP references" })

  map("n", "gi", function()
    -- vim.lsp.buf.implementation()
    trouble_open { mode = "lsp_implementations" }
  end, { buffer = bufnr, desc = "Go to implementation" })

  map("n", "<leader>ls", function()
    vim.lsp.buf.signature_help()
  end, { buffer = bufnr, desc = "Signature help" })

  utils.map_repeatable_pair("n", {
    next = {
      "]d",
      function()
        vim.diagnostic.jump { count = 1 }
      end,
      { buffer = bufnr, desc = "Go to next diagnostic" },
    },
    prev = {
      "[d",
      function()
        vim.diagnostic.jump { count = -1 }
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

  map("n", "<leader>ih", function()
    local new_value = not vim.lsp.inlay_hint.is_enabled()
    vim.lsp.inlay_hint.enable(new_value)
    vim.notify("Inlay hints " .. (new_value and "enabled" or "disabled"))
  end, { buffer = bufnr, desc = "toggle inlay hint" })

  vim.b[bufnr].lsp_keymaps_set = true
end

local no_format = {
  ["eslint"] = true, -- don't auto fix eslint errors
  ["cmake"] = true,
}
function M.formatter_filter(client)
  if no_format[client.name] then
    return false
  end
  local null_ls = require "null-ls"
  if client.name == "ts_ls" and null_ls.is_registered "prettierd" then
    return false
  end
  if client.name == "lua_ls" and null_ls.is_registered "stylua" then
    return false
  end
  return true
end

function M.on_attach(client, bufnr)
  set_keymaps(bufnr)

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true)
  end

  if (client.supports_method "textDocument/formatting" and M.formatter_filter(client)) or client.name == "jdtls" then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      desc = ("Format buffer with %s"):format(client.name),
      callback = function()
        if vim.g.FormatOnSave == 0 then
          return
        end
        vim.lsp.buf.format { id = client.id }
      end,
    })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("FormatOnSaveEnable", function()
    vim.g.FormatOnSave = nil
  end, {})
  vim.api.nvim_create_user_command("FormatOnSaveDisable", function()
    vim.g.FormatOnSave = 0
  end, {})
  vim.api.nvim_create_user_command("FormatBuffer", function()
    vim.lsp.buf.format { filter = M.formatter_filter }
  end, {})

  vim.api.nvim_create_user_command("DetachLsp", function()
    vim.diagnostic.reset(nil, 0)
    local clients = vim.lsp.get_clients { bufnr = 0 }
    vim.schedule(function()
      for _, client in ipairs(clients) do
        vim.lsp.buf_detach_client(0, client.id)
      end
    end)
  end, {})

  local no_lsp_filetype = {
    ["toggleterm"] = true,
    ["help"] = true,
    ["log"] = true,
    ["bigfile"] = true,
  }
  -- disable lsp for certain filetypes and in diff mode
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("DisableLsp", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client_id = args.data.client_id
      if no_lsp_filetype[vim.bo[bufnr].filetype] or vim.wo.diff then
        vim.schedule(function()
          vim.lsp.buf_detach_client(bufnr, client_id)
          vim.diagnostic.reset(nil, bufnr)
        end)
        return
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LspOnAttach", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client_id = args.data.client_id
      M.on_attach(vim.lsp.get_client_by_id(client_id), bufnr)
    end,
  })
end

function M.cond()
  return not require("modes").minimal_mode
end

return M
