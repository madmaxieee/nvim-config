local lsp_config = require "plugins.lsp.config"
local lsp_utils = require "plugins.lsp.utils"

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
        custom.bpfmt,
        custom.google_java_format,
        custom.trailing_ws,
        custom.trailing_ws_action,
        custom.cpplint,
      }

      local sources_map = {}
      for _, source in ipairs(sources) do
        if type(source) == "function" then
          source = source()
        end
        if source then
          sources_map[source.name] = source
        end
      end

      null_ls.setup {
        sources = sources,
        on_attach = lsp_config.on_attach,
      }

      vim.api.nvim_create_user_command("NullLsEnable", function(opts)
        local source_name = opts.args
        lsp_utils.set_lsp_enabled(source_name, true)
        local source = sources_map[source_name]
        if not source then
          vim.notify(("Unknown null-ls source: %s"):format(source_name), vim.log.levels.ERROR)
          return
        end
        if null_ls.is_registered(source_name) then
          null_ls.enable(source_name)
        else
          null_ls.register(source)
        end
      end, {
        nargs = 1,
        complete = function()
          return vim.tbl_keys(sources_map)
        end,
      })

      vim.api.nvim_create_user_command("NullLsDisable", function(opts)
        local source_name = opts.args
        lsp_utils.set_lsp_enabled(source_name, false)
        local source = sources_map[source_name]
        if not source then
          vim.notify(("Unknown null-ls source: %s"):format(source_name), vim.log.levels.ERROR)
          return
        end
        if null_ls.is_registered(source_name) then
          null_ls.disable(source_name)
        end
      end, {
        nargs = 1,
        complete = function()
          return vim.tbl_keys(sources_map)
        end,
      })

      vim.api.nvim_create_autocmd("SessionLoadPost", {
        group = vim.api.nvim_create_augroup("null-ls.global_var_disable", { clear = true }),
        callback = function()
          for name, _ in pairs(sources_map) do
            if not lsp_utils.get_lsp_enabled(name) and null_ls.is_registered(name) then
              null_ls.disable(name)
            end
          end
        end,
      })
    end,
  },
}
