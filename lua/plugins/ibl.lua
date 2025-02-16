return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },

  {
    "echasnovski/mini.indentscope",
    event = "VeryLazy",
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        desc = "Set mini.indentscope highlight",
        callback = function()
          local special_fg = vim.api.nvim_get_hl(0, { name = "Special" }).fg
          local color_utils = require "utils.colors"
          vim.api.nvim_set_hl(0, "SpecialDimmed", { fg = color_utils.blend_bg(special_fg, 0.4) })
        end,
      })
    end,
    config = function()
      require("mini.indentscope").setup {
        draw = {
          delay = 0,
          animation = function()
            return 0
          end,
        },
        mappings = {
          object_scope = "",
          object_scope_with_border = "",
          goto_top = "",
          goto_bottom = "",
        },
        symbol = "▎",
      }
      vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "SpecialDimmed" })
      local map = require("utils").safe_keymap_set
      map( --
        { "x", "o" },
        "ii",
        function()
          require("mini.indentscope").textobject(false)
        end,
        { desc = "Select inside indent scope" }
      )
      map( --
        { "x", "o" },
        "ai",
        function()
          require("mini.indentscope").textobject(true)
        end,
        { desc = "Select around indent scope" }
      )
    end,
  },
}
