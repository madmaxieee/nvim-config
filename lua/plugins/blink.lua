return {
  {
    "saghen/blink.compat",
    version = "*",
    opts = {},
  },

  {
    "saghen/blink.cmp",
    version = "v0.*",
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
      },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
