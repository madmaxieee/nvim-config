local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics
-- local actions = null_ls.builtins.code_actions

local shellcheck_cache = {}
shellcheck_cache.next_key = 0
shellcheck_cache.cache = {}
shellcheck_cache.by_bufnr = function(cb)
  -- assign next available key, since we just want to avoid collisions
  local key = shellcheck_cache.next_key
  shellcheck_cache.cache[key] = {}
  shellcheck_cache.next_key = shellcheck_cache.next_key + 1
  return function(params)
    local bufnr = params.bufnr
    -- if we haven't cached a value yet, get it from cb
    if shellcheck_cache.cache[key][bufnr] == nil then
      -- make sure we always store a value so we know we've already called cb
      shellcheck_cache.cache[key][bufnr] = cb(params) or false
    end
    return shellcheck_cache.cache[key][bufnr]
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
  formatting.bibclean.with {
    command = { "bibclean", "-max-width", "0" },
  },

  lint.fish,
  lint.cmake_lint,

  lint.shellcheck.with {
    runtime_condition = shellcheck_cache.by_bufnr(function(params)
      local bufname = vim.api.nvim_buf_get_name(params.bufnr)
      if bufname:match "%.env.*" then
        vim.notify "shellcheck disabled for .env.* files"
        return false
      else
        return true
      end
    end),
  },
}

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
