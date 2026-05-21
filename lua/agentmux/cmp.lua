---@type table<vim.lsp.protocol.Method, fun(params: table, callback:fun(err: lsp.ResponseError?, result: any))>
local handlers = {}
local ms = vim.lsp.protocol.Methods

---@param params lsp.InitializeParams
---@param callback fun(err?: lsp.ResponseError, result: lsp.InitializeResult)
handlers[ms.initialize] = function(params, callback)
  callback(nil, {
    capabilities = {
      completionProvider = {
        resolveProvider = true,
        triggerCharacters = { "@" },
      },
    },
    serverInfo = {
      name = "agentmux_ask_cmp",
    },
  })
end

---@param params lsp.CompletionParams
---@param callback fun(err?: lsp.ResponseError, result: lsp.CompletionItem[])
handlers[ms.textDocument_completion] = function(params, callback)
  local items = {}
  local context = require("agentmux.context")

  for name, _ in pairs(context.contexts) do
    local placeholder = "@" .. name
    ---@type lsp.CompletionItem
    local item = {
      label = placeholder,
      filterText = placeholder,
      insertText = placeholder,
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
      kind = vim.lsp.protocol.CompletionItemKind.Variable,
    }
    table.insert(items, item)
  end

  callback(nil, items)
end

---@param params lsp.CompletionItem
---@param callback fun(err?: lsp.ResponseError, result: lsp.CompletionItem)
handlers[ms.completionItem_resolve] = function(params, callback)
  callback(nil, vim.deepcopy(params))
end

---An in-process LSP that provides completions for agentmux context placeholders.
---@type vim.lsp.Config
return {
  name = "agentmux_ask_cmp",
  -- Note the filetype has no effect because `snacks.input` buftype is `prompt`.
  -- Instead, we manually start the LSP in a callback.
  filetypes = { "agentmux_ask" },
  cmd = function(dispatchers, config)
    return {
      request = function(method, params, callback)
        if handlers[method] then
          handlers[method](params, callback)
        end
      end,
      notify = function() end,
      is_closing = function()
        return false
      end,
      terminate = function() end,
    }
  end,
}