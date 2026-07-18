---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        -- external
        -- keep-sorted start
        bp = { "bpfmt" },
        d2 = { "d2" },
        fennel = { "fnlfmt" },
        fish = { "fish_indent" },
        java = { "google-java-format" },
        just = { "just" },
        nix = { "nixfmt" },
        -- keep-sorted end

        -- mason
        -- keep-sorted start
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        kdl = { "kdlfmt" },
        lua = { "stylua" },
        markdown = { "rumdl", lsp_format = "prefer" },
        mdx = { "prettierd" },
        svelte = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        typst = { "typstyle" },
        -- keep-sorted end

        -- mixed
        python = function(bufnr)
          if
            require("flags").in_google3
            and require("conform").get_formatter_info("pyformat", bufnr).available
          then
            -- external
            return { "pyformat" }
          else
            -- mason
            return { "ruff_organize_imports", "ruff_format" }
          end
        end,

        -- other
        ["_"] = { lsp_format = "last" },
        ["*"] = { "keep-sorted" },
      },
      formatters = {
        bpfmt = function()
          if vim.env.ANDROID_BUILD_TOP then
            return {
              inherit = "bpfmt",
              command = ("%s/prebuilts/build-tools/linux-x86/bin/bpfmt"):format(
                vim.env.ANDROID_BUILD_TOP
              ),
            }
          else
            return { inherit = "bpfmt" }
          end
        end,
        ["google-java-format"] = function()
          if vim.env.ANDROID_BUILD_TOP then
            return { prepend_args = { "--aosp" } }
          else
            return {}
          end
        end,
        pyformat = { command = "pyformat", args = {}, stdin = true },
        rumdl = {
          prepend_args = {
            "--config",
            "MD060.enabled=true",
            "--config",
            "MD013.line-length=80",
            "--config",
            "MD013.reflow=true",
          },
        },
      },
      format_on_save = function(bufnr)
        if vim.g.DisableAutoFormat or vim.b[bufnr].DisableAutoFormat then
          return
        end
        local file_path = vim.api.nvim_buf_get_name(bufnr)
        local file_name = vim.fs.basename(file_path)
        if file_name == "lazy-lock.json" then
          return
        end
        return { timeout_ms = 1000 }
      end,
    },

    init = function()
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.DisableAutoFormat = true
        else
          vim.g.DisableAutoFormat = true
        end
      end, {
        desc = "Disable autoformat on save",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.DisableAutoFormat = false
        vim.g.DisableAutoFormat = false
      end, {
        desc = "Re-enable autoformat on save",
      })

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line =
            vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({
          async = true,
          range = range,
          timeout_ms = 1000,
        })
      end, { range = true })

      vim.cmd.cabbrev("F", "Format")
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "google-java-format",
        "kdlfmt",
        "prettierd",
        "ruff",
        "rumdl",
        "stylua",
        "typstyle",
      },
    },
    opts_extend = { "ensure_installed" },
  },
}
