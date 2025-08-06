local lsp_config = require "plugins.lsp.config"

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- formatting
        "isort",
        "prettierd",
        "stylua",
        "typstyle",
        -- linting
        "checkstyle",
        -- custom
        "cpplint",
      },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    cond = not require("modes").minimal_mode,
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
        formatting.typstyle,
        lint.checkstyle.with {
          extra_args = { "-c", (vim.fn.stdpath "config") .. "/misc/google_checks.xml" },
        },
        -- external
        formatting.d2_fmt,
        formatting.fish_indent,
        formatting.just,
        formatting.nixfmt,
        formatting.xmllint,
        lint.fish,
        -- custom
        custom.trailing_ws,
        custom.trailing_ws_action,
        custom.bpfmt,
      }

      null_ls.setup {
        sources = sources,
        on_attach = lsp_config.on_attach,
      }

      vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = vim.api.nvim_create_augroup("Cpplint", { clear = true }),
        desc = "setup cpplint",
        callback = function()
          if vim.g.Cpplint == 1 and not null_ls.is_registered "cpplint" then
            null_ls.register(custom.cpplint)
          end
        end,
      })

      vim.api.nvim_create_user_command("Cpplint", function()
        vim.g.Cpplint = 1
        if null_ls.is_registered "cpplint" then
          null_ls.enable "cpplint"
        else
          null_ls.register(custom.cpplint)
        end
      end, {})

      vim.api.nvim_create_user_command("CpplintDisable", function()
        vim.g.Cpplint = nil
        if null_ls.is_registered "cpplint" then
          null_ls.disable "cpplint"
        end
      end, {})
    end,
  },
}
