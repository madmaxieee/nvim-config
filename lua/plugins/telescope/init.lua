local data = assert(vim.fn.stdpath "data") --[[@as string]]

return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy", -- for neoclip to work
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-smart-history.nvim",
      "debugloop/telescope-undo.nvim",
      "AckslD/nvim-neoclip.lua",
    },
    keys = {
      {
        "<leader>gg",
        mode = "n",
        "<cmd> Telescope git_files <CR>",
        desc = "Find git files",
      },
      {
        "<leader>fd",
        mode = "n",
        "<cmd> Telescope diagnostics <CR>",
        desc = "Find diagnostic",
      },
      {
        "<leader>fs",
        mode = "n",
        "<cmd> Telescope lsp_document_symbols <CR>",
        desc = "Search document symbols",
      },
      {
        "<leader>ws",
        mode = "n",
        "<cmd> Telescope lsp_dynamic_workspace_symbols <CR>",
        desc = "Search workspace symbols",
      },
      {
        "<leader>fm",
        mode = "n",
        "<cmd> Telescope marks <CR>",
        desc = "Search marks",
      },
      {
        "<leader>fj",
        mode = "n",
        "<cmd> Telescope jumplist <CR>",
        desc = "Search jumplist",
      },
      {
        "<leader>fg",
        mode = "n",
        "<cmd> Telescope git_status <CR>",
        desc = "Git status",
      },
      {
        "<leader>ff",
        mode = "n",
        "<cmd> Telescope find_files <CR>",
        desc = "Find files",
      },
      {
        "<leader>fa",
        mode = "n",
        "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
        desc = "Find all",
      },
      {
        "<leader>fw",
        mode = "n",
        -- "<cmd> Telescope live_grep <CR>",
        require "plugins.telescope.multi-grep",
        desc = "Multi grep",
      },
      {
        "<leader>fW",
        mode = "n",
        function()
          require("telescope.builtin").live_grep { additional_args = { "--hidden" } }
        end,
        desc = "Live grep including hidden files",
      },
      {
        "<leader>fb",
        mode = "n",
        "<cmd> Telescope buffers <CR>",
        desc = "Find buffers",
      },
      {
        "<leader>fh",
        mode = "n",
        "<cmd> Telescope help_tags <CR>",
        desc = "Help page",
      },
      {
        "<leader>fz",
        mode = "n",
        "<cmd> Telescope current_buffer_fuzzy_find <CR>",
        desc = "Find in current buffer",
      },
      {
        "<leader>fr",
        mode = "n",
        "<cmd> Telescope resume <CR>",
        desc = "Telescope resume",
      },
      {
        "<leader>cm",
        mode = "n",
        "<cmd> Telescope git_commits <CR>",
        desc = "Git commits",
      },
      {
        "<leader>fw",
        mode = "v",
        function()
          require("telescope.builtin").grep_string { path_display = { "shorten" } }
        end,
        desc = "Grep string",
      },
      {
        "<leader>fu",
        mode = "n",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
      {
        "<leader>p",
        mode = "n",
        "<cmd>Telescope neoclip<cr>",
        desc = "neoclip",
      },
    },
    cmd = "Telescope",
    init = function()
      vim.cmd.cabbrev("T", "Telescope")
    end,

    config = function()
      local actions = require "telescope.actions"
      require("telescope").setup {
        defaults = {
          vimgrep_arguments = {
            "rg",
            "-L",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
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
        },
        extensions = {
          fzf = {},
          history = {
            path = vim.fs.joinpath(data, "telescope_history.sqlite3"),
            limit = 100,
          },
          undo = {
            mappings = {
              n = { ["<cr>"] = require("telescope-undo.actions").restore },
            },
          },
        },
      }
      require("telescope").load_extension "undo"
      require("telescope").load_extension "fzf"
      require("telescope").load_extension "neoclip"
      require("telescope").load_extension "macroscope"
    end,
  },

  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua" },
    config = function()
      require("neoclip").setup {
        enable_persistent_history = true,
        keys = {
          telescope = {
            i = {
              select = "<c-y>",
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
    "axkirillov/easypick.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    cmd = "Easypick",
    config = function()
      local easypick = require "easypick"
      easypick.setup {
        pickers = {
          {
            name = "today",
            command = "fd --type file --changed-within 1d",
            previewer = easypick.previewers.default(),
          },
          {
            name = "week",
            command = "fd --type file --changed-within 1w",
            previewer = easypick.previewers.default(),
          },
        },
      }
    end,
  },
}
