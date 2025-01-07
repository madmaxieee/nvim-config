local vault_folder = vim.fn.resolve(vim.fn.expand "~/obsidian")

return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    event = {
      "BufReadPre " .. vault_folder .. "/**.md",
      "BufNewFile " .. vault_folder .. "/**.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/obsidian/notes",
        },
      },
      completion = {
        -- register sources manually in helper
        nvim_cmp = false,
        min_chars = 2,
      },
      mappings = {
        ["gd"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        ["<leader>fo"] = {
          action = function()
            vim.cmd "ObsidianSearch"
          end,
          opts = { buffer = false },
        },
      },
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,
    },
    config = function(_, opts)
      require("obsidian").setup(opts)

      local config = require "plugins.obsidian.config"

      config.create_obsidian_command()
      config.setup_auto_commit {
        vault_folder = vault_folder,
        auto_save_interval = 10 * 60,
        commit_interval = 60 * 60,
      }
      config.register_sources()

      vim.wo.conceallevel = 1
    end,
  },

  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = {
          "obsidian",
          "obsidian_new",
          "obsidian_tags",
        },
        providers = {
          obsidian = {
            name = "obsidian",
            module = "blink.compat.source",
          },
          obsidian_new = {
            name = "obsidian_new",
            module = "blink.compat.source",
          },
          obsidian_tags = {
            name = "obsidian_tags",
            module = "blink.compat.source",
          },
        },
      },
    },
  },
}
