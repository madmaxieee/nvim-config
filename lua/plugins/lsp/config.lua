local M = {}

local utils = require "utils"
local lsp_utils = require "plugins.lsp.utils"
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

  map({ "n", "v" }, "<leader>F", function()
    vim.lsp.buf.format { filter = M.formatter_filter }
  end, { buffer = bufnr, desc = "Format buffer/range" })

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
  if client.name == "jdtls" and null_ls.is_registered "google-java-format" then
    return false
  end
  return true
end

function M.on_attach(client, bufnr)
  set_keymaps(bufnr)

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true)
  end

  if (client.supports_method "textDocument/formatting" or client.name == "jdtls") and M.formatter_filter(client) then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      desc = ("Format buffer with %s"):format(client.name),
      callback = function()
        if vim.g.FormatOnSave == 0 then
          return
        end
        if M.formatter_filter(client) then
          vim.lsp.buf.format { id = client.id }
        end
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

  vim.api.nvim_create_user_command("Format", function(opts)
    if opts.range == 0 then
      vim.lsp.buf.format { filter = M.formatter_filter }
    else
      vim.cmd "normal! gv"
      vim.lsp.buf.format { filter = M.formatter_filter }
    end
  end, { range = true })

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
  local function should_disable_lsp(client, bufnr)
    if vim.wo.diff then
      return true
    end

    local no_lsp_filetype = {
      ["toggleterm"] = true,
      ["help"] = true,
      ["log"] = true,
      -- from snacks bigfile
      ["bigfile"] = true,
    }

    if no_lsp_filetype[vim.bo[bufnr].filetype] then
      return true
    end

    if not lsp_utils.get_lsp_enabled(client.name) then
      return true
    end

    -- lsp specific disable rules
    if client.name == "typos_lsp" then
      if vim.o.readonly or vim.bo[bufnr].filetype == "oil" then
        return true
      end
    end

    return false
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("DisableLsp", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client_id = args.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)
      if should_disable_lsp(client, bufnr) then
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
