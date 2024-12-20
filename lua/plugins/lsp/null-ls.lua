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
      formatting.fish_indent,
      formatting.typstfmt,
      formatting.bibclean.with {
        command = { "bibclean", "-max-width", "0" },
      },
      formatting.nixfmt,
      formatting.d2_fmt,
      formatting.just,

      lint.checkstyle.with {
        extra_args = { "-c", (vim.fn.stdpath "config") .. "/misc/google_checks.xml" },
      },
      lint.fish,
    }

    null_ls.setup {
      sources = sources,
      on_attach = on_attach,
    }

    local no_trailing_space = {
      method = null_ls.methods.DIAGNOSTICS,
      filetypes = {},
      generator = {
        fn = function(params)
          local diagnostics = {}
          for i, line in ipairs(params.content) do
            local col, end_col = line:find "%s+$"
            if col and end_col then
              table.insert(diagnostics, {
                row = i,
                col = col,
                end_col = end_col + 1,
                source = "no-trailing-space",
                message = "no trailing whitespace!",
                severity = vim.diagnostic.severity.WARN,
              })
            end
          end
          return diagnostics
        end,
      },
    }

    null_ls.register(no_trailing_space)
  end,
}
