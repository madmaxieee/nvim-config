local lsp_config = require "plugins.lsp.config"

return {
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- formatting
        "prettierd",
        "stylua",
        "isort",
        "fish_indent",
        "typstfmt",
        "bibclean",
        -- linting
        "checkstyle",
      },
    },
  },

  {
    cond = lsp_config.cond(),
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-null-ls.nvim",
    },
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
        on_attach = lsp_config.on_attach,
      }

      null_ls.register {
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
    end,
  },
}
