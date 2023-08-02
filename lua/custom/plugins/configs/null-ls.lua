local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics
local actions = null_ls.builtins.code_actions

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

  lint.shellcheck,
  lint.ruff,
  lint.fish,
  lint.eslint_d,
  lint.fish,
  lint.cmake_lint,

  actions.eslint_d,
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
