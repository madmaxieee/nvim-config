local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics
-- local actions = null_ls.builtins.code_actions

local cache = {}
cache.next_key = 0
cache.cache = {}
cache.by_bufnr = function(cb)
  -- assign next available key, since we just want to avoid collisions
  local key = cache.next_key
  cache.cache[key] = {}
  cache.next_key = cache.next_key + 1
  return function(params)
    local bufnr = params.bufnr
    -- if we haven't cached a value yet, get it from cb
    if cache.cache[key][bufnr] == nil then
      -- make sure we always store a value so we know we've already called cb
      cache.cache[key][bufnr] = cb(params) or false
    end
    return cache.cache[key][bufnr]
  end
end

local sources = {
  formatting.prettierd,
  formatting.stylua,
  formatting.clang_format,
  formatting.isort,
  formatting.black,
  formatting.fish_indent,
  formatting.rustfmt,
  formatting.cmake_format,
  formatting.beautysh,

  -- lint.ruff,
  lint.fish,
  lint.cmake_lint,

  -- lint.shellcheck.with {
  --   runtime_condition = cache.by_bufnr(function(params)
  --     local bufname = vim.api.nvim_buf_get_name(params.bufnr)
  --     if bufname:match "%.env.*" then
  --       vim.notify "shellcheck disabled for .env.* files"
  --       return false
  --     else
  --       return true
  --     end
  --   end),
  -- },
}

if vim.fn.executable "prettierd" == 0 then
  vim.notify "prettierd not found, install with: pnpm i -g @fsouza/prettierd"
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup {
  -- debug = true,
  sources = sources,
  -- you can reuse a shared lspconfig on_attach callback here
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { async = false }
        end,
      })
    end
  end,
}
