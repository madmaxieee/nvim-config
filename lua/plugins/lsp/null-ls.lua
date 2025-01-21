local lsp_config = require "plugins.lsp.config"

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- formatting
        "prettierd",
        "stylua",
        "isort",
        -- linting
        "checkstyle",
        -- custom
        "cpplint",
      },
    },
  },

  {
    cond = lsp_config.cond(),
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local null_ls = require "null-ls"

      local formatting = null_ls.builtins.formatting
      local lint = null_ls.builtins.diagnostics
      -- local actions = null_ls.builtins.code_actions
      local custom = require "plugins.lsp.custom"

      local sources = {
        -- managed
        formatting.isort,
        formatting.prettierd,
        formatting.stylua,
        lint.checkstyle.with {
          extra_args = { "-c", (vim.fn.stdpath "config") .. "/misc/google_checks.xml" },
        },
        -- external
        formatting.d2_fmt,
        formatting.fish_indent,
        formatting.just,
        formatting.nixfmt,
        lint.fish,
        -- custom
        custom.cpplint,
        custom.trailing_ws,
      }

      null_ls.setup {
        sources = sources,
        on_attach = lsp_config.on_attach,
      }
    end,
  },
}
