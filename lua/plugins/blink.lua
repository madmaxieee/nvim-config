return {
  {
    "saghen/blink.compat",
    version = "*",
    opts = {},
  },

  {
    "saghen/blink.cmp",
    version = "v1.*",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "folke/lazydev.nvim",
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<A-space>"] = { "show", "show_documentation", "hide_documentation" },
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
}
