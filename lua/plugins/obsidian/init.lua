local vault_folder = vim.fn.resolve(vim.fn.expand "~/obsidian")

return {
  {
    cond = vim.startswith(vim.uv.cwd() or "", vault_folder),
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/obsidian/notes",
        },
      },
      completion = {
        blink = true,
        min_chars = 2,
      },
      picker = {
        name = "snacks.pick",
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
      legacy_commands = false,
    },
    init = function()
      local map = require("utils").safe_keymap_set

      vim.api.nvim_create_autocmd("User", {
        pattern = "ObsidianNoteEnter",
        callback = function(opts)
          vim.wo.conceallevel = 1
          map("n", "gd", function()
            return require("obsidian").util.gf_passthrough()
          end, {
            buffer = opts.buf,
            expr = true,
            desc = "Go to definition",
          })
          map("n", "<cr>", function()
            require("obsidian").util.toggle_checkbox()
          end, {
            buffer = opts.buf,
            desc = "Toggle checkbox",
          })
        end,
      })

      map("n", "<leader>fo", "<cmd>Obsidian search<cr>", {})

      vim.cmd.cabbrev("O", "Obsidian")
    end,
    config = function(_, opts)
      require("obsidian").setup(opts)
      require("plugins.obsidian.config").setup_auto_commit {
        vault_folder = vault_folder,
        auto_save_interval = 10 * 60,
        commit_interval = 60 * 60,
      }
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
    opts_extend = { "sources.default" },
  },
}
