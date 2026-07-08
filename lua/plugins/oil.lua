return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Oil",
  keys = {
    {
      "<leader>o",
      mode = "n",
      function()
        local oil = require("oil")
        if vim.bo.filetype == "oil" then
          oil.close()
        else
          oil.open_float(
            nil,
            {},
            vim.schedule_wrap(function()
              oil.open_preview({ vertical = true })
            end)
          )
        end
      end,
      desc = "Toggle oil",
    },
    {
      "-",
      mode = "n",
      "<cmd>Oil --preview<cr>",
      desc = "Open oil",
    },
  },
  opts = {
    delete_to_trash = true,
    float = {
      border = "rounded",
      -- roughly the same size as snacks.picker
      max_width = 0.78,
      max_height = 0.78,
    },
    preview_win = {
      win_options = {
        wrap = false,
      },
    },
    keymaps = {
      ["<C-h>"] = {},
      ["<C-l>"] = {},
      ["<leader><space>"] = "actions.refresh",
      ["gd"] = {
        desc = "Toggle file detail view",
        callback = function()
          vim.g.oil_detail = not vim.g.oil_detail
          if vim.g.oil_detail then
            require("oil").set_columns({
              "icon",
              "permissions",
              "size",
              "mtime",
            })
          else
            require("oil").set_columns({ "icon" })
          end
        end,
      },
    },
  },
}
