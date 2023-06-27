local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics
local actions = null_ls.builtins.code_actions

local sources = {
  formatting.prettier,
  formatting.stylua,
  formatting.clang_format,
  formatting.isort,
  formatting.black,

  lint.shellcheck,
  lint.ruff,
  lint.mypy,

  actions.eslint,
}

-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup {
  debug = true,
  sources = sources,
  -- you can reuse a shared lspconfig on_attach callback here
  -- on_attach = function(client, bufnr)
  --   if client.supports_method "textDocument/formatting" then
  --     vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
  --     vim.api.nvim_create_autocmd("BufWritePre", {
  --       group = augroup,
  --       buffer = bufnr,
  --       callback = function()
  --         -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
  --         -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
  --         vim.lsp.buf.formatting_sync()
  --       end,
  --     })
  --   end
  -- end,
}
