return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "natecraddock/telescope-zf-native.nvim",
      "debugloop/telescope-undo.nvim",
      "AckslD/nvim-neoclip.lua",
      "danielfalk/smart-open.nvim",
    },
    cmd = "Telescope",
    init = function()
      vim.cmd.cabbrev("T", "Telescope")
      require("plugins.fuzzy-finder.telescope.keymaps").set_keymaps()
    end,

    config = function()
      local actions = require "telescope.actions"
      require("telescope").setup {
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--follow",
          },
          prompt_prefix = "   ",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
            },
          },
          file_ignore_patterns = {
            "node_modules/",
            "%.venv/",
            "%.git/",
            "%.obsidian%-?.*/",
            "lazy%-lock%.json$",
            "pnpm%-lock%.yaml$",
            "package%-lock%.json$",
            "yarn%.lock$",
          },
          mappings = {
            i = {
              ["<c-t>"] = function(prompt_bufnr)
                local trouble = require "trouble.providers.telescope"
                trouble.open_with_trouble(prompt_bufnr)
              end,
              ["<c-f>"] = actions.to_fuzzy_refine,
            },
            n = {
              ["<c-t>"] = function(prompt_bufnr)
                require "telescope.actions"
                local trouble = require "trouble.providers.telescope"
                trouble.open_with_trouble(prompt_bufnr)
              end,
              ["<c-f>"] = actions.to_fuzzy_refine,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          buffers = {
            mappings = {
              n = {
                ["x"] = actions.delete_buffer,
              },
            },
          },
        },
        extensions = {
          undo = {
            mappings = {
              n = { ["<cr>"] = require("telescope-undo.actions").restore },
            },
          },
        },
      }
      require("telescope").load_extension "zf-native"
      require("telescope").load_extension "undo"
      require("telescope").load_extension "neoclip"
      require("telescope").load_extension "macroscope"
      require("telescope").load_extension "smart_open"
    end,
  },

  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua" },
    event = "VeryLazy", -- start recording registers
    config = function()
      require("neoclip").setup {
        enable_persistent_history = true,
        keys = {
          telescope = {
            i = {
              select = "<c-y>",
              paste = false,
              paste_behind = "<c-k>",
              replay = "<c-q>", -- replay a macro
              delete = "<c-d>", -- delete an entry
              edit = "<c-e>", -- edit an entry
              custom = {
                -- HACK: pasting in insert mode telescope somehow incorrectly moves the curosr
                -- this is a workaround to move the cursor back to the right position
                ["<cr>"] = function(opts)
                  local handlers = require "neoclip.handlers"
                  vim.cmd "norm! h"
                  handlers.paste(opts.entry, "p")
                  vim.cmd "norm! l"
                end,
              },
            },
            n = {
              select = "y",
              paste = { "<cr>", "p" },
              paste_behind = "P",
              replay = "q",
              delete = "d",
              edit = "e",
            },
          },
        },
      }
    end,
  },

  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    dependencies = {
      "kkharji/sqlite.lua",
    },
  },
}
