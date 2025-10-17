local M = {}

local utils = require "utils"
local map = utils.safe_keymap_set
local lsp_utils = require "plugins.lsp.utils"
local set_keymaps = require("plugins.lsp.keymaps").set_keymaps

local no_lsp_filetype = {
  ["toggleterm"] = true,
  ["help"] = true,
  ["log"] = true,
  -- from snacks bigfile
  ["bigfile"] = true,
}
-- disable lsp for certain filetypes and in diff mode
---@param client vim.lsp.Client
---@param bufnr number
local function should_disable_lsp(client, bufnr)
  if vim.wo.diff then
    return true
  end
  if no_lsp_filetype[vim.bo[bufnr].filetype] then
    return true
  end
  if not lsp_utils.lsp_is_enabled(client.name) then
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

---@param client vim.lsp.Client
---@param bufnr number
function M.on_attach(client, bufnr)
  set_keymaps(bufnr)

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  if client:supports_method "textDocument/inlineCompletion" then
    vim.lsp.inline_completion.enable(true)
    map("i", "<A-l>", function()
      vim.lsp.inline_completion.get()
    end, { buffer = bufnr, desc = "Accept inline completion" })
  end

  local formatter_filter = lsp_utils.make_formatter_filter(bufnr)
  if (client:supports_method "textDocument/formatting" or client.name == "jdtls") and formatter_filter(client) then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      group = vim.api.nvim_create_augroup(
        ("lsp.buf[%d].formatOnSave: %s"):format(bufnr, client.name),
        { clear = true }
      ),
      desc = ("Format buffer with %s"):format(client.name),
      callback = function()
        if vim.g.FormatOnSave == 0 then
          return
        end
        if formatter_filter(client) then
          vim.lsp.buf.format { id = client.id }
        end
      end,
    })
  end
end

function M.on_detach(client, bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if client:supports_method "textDocument/inlineCompletion" then
    vim.lsp.inline_completion.enable(false, { bufnr = bufnr })
    for _, other_client in ipairs(clients) do
      if other_client.id ~= client.id and other_client:supports_method "textDocument/inlineCompletion" then
        vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
        break
      end
    end
  end
end

---@param opts {servers:string[]}
function M.init(opts)
  local servers = opts.servers

  -- do normal on attach/detach work
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp.attach", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client_id = args.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)
      assert(client)
      M.on_attach(client, bufnr)
    end,
  })
  vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("lsp.detach", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client_id = args.data.client_id
      M.on_detach(vim.lsp.get_client_by_id(client_id), bufnr)
    end,
  })

  -- formatting
  vim.api.nvim_create_user_command("FormatOnSaveEnable", function()
    vim.g.FormatOnSave = nil
  end, {})
  vim.api.nvim_create_user_command("FormatOnSaveDisable", function()
    vim.g.FormatOnSave = 0
  end, {})

  vim.api.nvim_create_user_command("Format", function(args)
    local formatter_filter = lsp_utils.make_formatter_filter()
    if args.range == 0 then
      vim.lsp.buf.format { filter = formatter_filter }
    else
      vim.cmd "normal! gv"
      vim.lsp.buf.format { filter = formatter_filter }
    end
  end, { range = true })
  vim.cmd.cabbrev("F", "Format")

  -- detach lsps from current buffer
  vim.api.nvim_create_user_command("DetachLsp", function()
    vim.diagnostic.reset(nil, 0)
    local clients = vim.lsp.get_clients { bufnr = 0 }
    vim.schedule(function()
      for _, client in ipairs(clients) do
        vim.lsp.buf_detach_client(0, client.id)
      end
    end)
  end, {})

  -- disable lsp servers per buffer under some conditions
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp.disable.buffer", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client_id = args.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)
      assert(client)
      if should_disable_lsp(client, bufnr) then
        vim.schedule(function()
          vim.lsp.buf_detach_client(bufnr, client_id)
          vim.diagnostic.reset(nil, bufnr)
        end)
        return
      end
    end,
  })

  -- enable/disable lsp servers per project with global variable
  vim.api.nvim_create_user_command("LspEnable", function(args)
    if not vim.tbl_contains(servers, args.args) then
      vim.notify(("Unknown LSP server: %s"):format(args.args), vim.log.levels.ERROR)
      return
    end
    lsp_utils.lsp_enable(args.args)
  end, {
    nargs = 1,
    complete = function()
      return servers
    end,
  })

  vim.api.nvim_create_user_command("LspDisable", function(args)
    if not vim.tbl_contains(servers, args.args) then
      vim.notify(("Unknown LSP server: %s"):format(args.args), vim.log.levels.ERROR)
      return
    end
    lsp_utils.lsp_disable(args.args)
  end, {
    nargs = 1,
    complete = function()
      return servers
    end,
  })

  vim.api.nvim_create_autocmd("SessionLoadPost", {
    group = vim.api.nvim_create_augroup("lsp.disable.project", { clear = true }),
    callback = function()
      for _, lsp in ipairs(servers) do
        if not lsp_utils.lsp_is_enabled(lsp) then
          vim.cmd("LspStop " .. lsp)
        end
      end
      vim.diagnostic.reset(nil, 0)
    end,
  })

  require "plugins.lsp.copilot"
end

---@alias ServerConfig vim.lsp.Config | fun(): vim.lsp.Config
---@param opts {servers:string[], server_configs:table<string, ServerConfig>}
function M.setup(opts)
  local servers = opts.servers
  local server_configs = opts.server_configs
  local capabilities = require("blink.cmp").get_lsp_capabilities()
  vim.lsp.config("*", { capabilities = capabilities })
  for lsp, config in pairs(server_configs) do
    if type(config) == "function" then
      config = config()
    end
    vim.lsp.config(lsp, config)
  end
  -- this reads the default values, since session is likely not loaded yet
  vim.lsp.enable(vim.tbl_filter(lsp_utils.lsp_is_enabled, servers))
end

return M
