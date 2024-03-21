local on_attach = require "plugins.lsp.on_attach"

return {
  cond = not vim.g.minimal_mode,
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local null_ls = require "null-ls"

    local formatting = null_ls.builtins.formatting
    local lint = null_ls.builtins.diagnostics
    -- local actions = null_ls.builtins.code_actions

    local sources = {
      formatting.prettierd,
      formatting.stylua,
      formatting.isort,
      formatting.black,
      formatting.fish_indent,
      formatting.typstfmt,
      formatting.bibclean.with {
        command = { "bibclean", "-max-width", "0" },
      },

      lint.fish,
    }

    null_ls.setup {
      sources = sources,
      on_attach = on_attach,
    }
  end,
}
