return {
  {
    "saghen/blink.compat",
    version = "*",
    opts = {},
  },

  {
    "saghen/blink.cmp",
    version = "v1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
      "folke/lazydev.nvim",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<C-n>"] = { "show", "select_next", "fallback_to_mappings" },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            direction_priority = {
              menu_north = { "w", "e", "n", "s" },
              menu_south = { "w", "e", "s", "n" },
            },
          },
        },
        accept = { auto_brackets = { enabled = true } },
        ghost_text = { enabled = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            fallbacks = {},
          },
          path = {
            score_offset = 3,
            fallbacks = {},
          },
          snippets = {
            score_offset = -3,
            fallbacks = {},
          },
          buffer = {
            score_offset = -10,
            fallbacks = {},
          },
        },
      },
      signature = { enabled = true },
      cmdline = {
        completion = {
          menu = { auto_show = true },
        },
      },
    },
    opts_extend = { "sources.default" },
  },

  {
    -- "saghen/blink.pairs",
    "madmaxieee/blink.pairs", -- for my abbr expand patch
    event = { "InsertEnter", "CmdlineEnter" },
    build = "cargo build --release",
    --- @module 'blink.pairs'
    --- @type blink.pairs.Config
    opts = {
      mappings = {
        enabled = true,
        cmdline = true,
        pairs = {
          ["!"] = {
            {
              "<!--",
              "-->",
              languages = { "html", "markdown", "markdown_inline" },
            },
          },
          ["("] = ")",
          ["["] = "]",
          ["{"] = "}",
          ["'"] = {
            { -- new
              "''",
              "''",
              when = function(ctx)
                return ctx:text_before_cursor(1) == "'"
              end,
              languages = { "nix" },
            },
            {
              "'''",
              when = function(ctx)
                return ctx:text_before_cursor(2) == "''"
              end,
              languages = {
                "python",
                "toml", -- new
              },
            },
            {
              "'",
              enter = false,
              space = false,
              when = function(ctx)
                return ctx.ft ~= "plaintext"
                  and not ctx.char_under_cursor:match("%w")
                  and ctx.ts:blacklist("singlequote").matches
              end,
            },
          },
          ['"'] = {
            {
              'r#"',
              '"#',
              languages = { "rust" },
              priority = 100,
            },
            {
              '"""',
              when = function(ctx)
                return ctx:text_before_cursor(2) == '""'
              end,
              languages = {
                "python",
                "elixir",
                "julia",
                "kotlin",
                "scala",
                "toml", -- new
              },
            },
            { '"', enter = false, space = false },
          },
          ["`"] = {
            {
              "```",
              when = function(ctx)
                return ctx:text_before_cursor(2) == "``"
              end,
              languages = {
                "markdown",
                "markdown_inline",
                "typst",
                "vimwiki",
                "rmarkdown",
                "rmd",
                "quarto",
              },
            },
            {
              "`",
              "'",
              languages = { "bibtex", "latex", "plaintex" },
            },
            { "`", enter = false, space = false },
          },
          ["_"] = {
            {
              "_",
              when = function(ctx)
                return not ctx.char_under_cursor:match("%w")
                  and ctx.ts:blacklist("underscore").matches
              end,
              languages = { "typst" },
            },
          },
          ["*"] = {
            {
              "*",
              when = function(ctx)
                return ctx.ts:blacklist("asterisk").matches
              end,
              languages = { "typst" },
            },
          },
          ["<"] = {
            {
              "<",
              ">",
              when = function(ctx)
                return ctx.ts:whitelist("angle").matches
              end,
              languages = { "rust" },
            },
          },
          ["$"] = {
            {
              "$",
              languages = {
                "markdown",
                "markdown_inline",
                "typst",
                "latex",
                "plaintex",
              },
            },
          },
        },
      },
      highlights = { enabled = false },
    },
  },
}
