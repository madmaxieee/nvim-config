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
      ["<S-CR>"] = {
        desc = "Open entry, preserving symlink file path",
        callback = function()
          local oil = require("oil")
          local actions = require("oil.actions")

          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()
          if not entry or not dir then
            actions.select.callback()
            return
          end

          local is_symlink_file = entry.type == "link"
            and vim.tbl_get(entry, "meta", "link_stat", "type") ~= "directory"

          if is_symlink_file then
            local path = vim.fs.joinpath(dir, entry.name)
            oil.close()
            vim.cmd.edit({ args = { path } })
          else
            actions.select.callback()
          end
        end,
      },
    },
  },
}
